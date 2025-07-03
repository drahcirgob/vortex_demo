// No arquivo: lib/screens/module_screen.dart

import 'package:flutter/material.dart';
import 'package:vortex_demo/models/module_model.dart';
import 'package:vortex_demo/services/firestore_service.dart';
import 'package:vortex_demo/services/auth_service.dart';
import 'package:vortex_demo/widgets/pill_renderer.dart';
import 'package:vortex_demo/widgets/audio_player_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ModuleScreen extends StatefulWidget {
  final String moduleId;
  const ModuleScreen({super.key, required this.moduleId});

  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  
  late Future<(Module, UserProgress?)> _dataFuture;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;
    _dataFuture = _loadModuleData();
  }

  Future<(Module, UserProgress?)> _loadModuleData() async {
    if (_currentUser == null) {
      throw Exception("Usuário não autenticado para carregar o módulo.");
    }
    final module = await _firestoreService.getModuleById(widget.moduleId);
    final userProgress = await _firestoreService.getUserProgress(_currentUser!.uid);
    return (module, userProgress);
  }

  Future<void> _completePill(String pillId) async {
    if (_currentUser == null) return;

    await _firestoreService.updatePillCompletion(_currentUser!.uid, widget.moduleId, pillId);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green[700],
          content: Text('Checkpoint $pillId alcançado!', style: const TextStyle(fontFamily: 'VT323')),
        )
      );
      
      // --- DIAGNÓSTICO AVANÇADO ---
      // Verificamos a conclusão do dia ANTES de recarregar os dados.
      await _checkDayCompletion();

      // Força a reconstrução da tela para refletir o novo progresso.
      setState(() {
        _dataFuture = _loadModuleData();
      });
    }
  }

  Future<void> _checkDayCompletion() async {
    if (_currentUser == null) return;

    // Usamos os dados já carregados para a verificação.
    final (module, userProgress) = await _dataFuture;
    final dayProgress = userProgress?.progress[widget.moduleId];

    if (dayProgress != null) {
      // --- LOGS DE DIAGNÓSTICO ---
      // Pega a lista de IDs de todas as pílulas do módulo.
      final allPillIdsInModule = module.contentPills.map((p) => p.pillId).toSet();
      // Pega a lista de IDs das pílulas que o usuário já completou.
      final completedPillIds = dayProgress.completedPills.toSet();

      debugPrint("--- VERIFICANDO CONCLUSÃO DO DIA ${widget.moduleId} ---");
      debugPrint("Pílulas necessárias para completar: ${allPillIdsInModule.toList()}");
      debugPrint("Pílulas já completadas pelo usuário: ${completedPillIds.toList()}");

      // A lógica de conclusão agora é: o conjunto de pílulas concluídas contém
      // todas as pílulas necessárias?
      final allPillsCompleted = completedPillIds.containsAll(allPillIdsInModule);
      
      debugPrint("Todas as pílulas foram concluídas? $allPillsCompleted");
      // --- FIM DOS LOGS DE DIAGNÓSTICO ---

      if (allPillsCompleted) {
        debugPrint("CONFIRMADO: Todas as pílulas do ${widget.moduleId} concluídas!");
        await _firestoreService.updateDayStatus(_currentUser!.uid, widget.moduleId, 'completed');
        
        final nextDayNumber = module.dayNumber + 1;
        if (nextDayNumber <= 10) {
          final nextDayId = 'dia-${nextDayNumber.toString().padLeft(2, '0')}';
          await _firestoreService.updateDayStatus(_currentUser!.uid, nextDayId, 'unlocked');
          debugPrint("Dia $nextDayId desbloqueado!");
        }

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(side: BorderSide(color: Colors.green[400]!)),
              title: Text('// MISSÃO ${module.dayNumber} CONCLUÍDA //', style: TextStyle(fontFamily: 'VT323', color: Colors.green)),
              content: Text('Você completou todos os objetivos do dia. O próximo módulo foi desbloqueado. Descanse, operador.', style: TextStyle(color: Colors.white)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('// ENTENDIDO //', style: TextStyle(fontFamily: 'VT323', color: Colors.green)),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // O resto do seu build method permanece o mesmo
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<(Module, UserProgress?)>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.green[400]));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar módulo: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Módulo não encontrado.', style: TextStyle(color: Colors.white)));
          }

          final (module, userProgress) = snapshot.data!;
          final dayProgress = userProgress?.progress[widget.moduleId];

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.green),
                title: Text('// ${module.title.toUpperCase()} //', style: const TextStyle(fontFamily: 'VT323', color: Colors.green, fontSize: 24)),
                floating: true,
              ),
              SliverToBoxAdapter(
                child: AudioPlayerWidget(audioUrl: module.audioSummaryUrl),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final pill = module.contentPills[index];
                    
                    final bool isPillCompleted = dayProgress?.completedPills.contains(pill.pillId) ?? false;
                    
                    bool isPillUnlocked = false;
                    if (index == 0) {
                      isPillUnlocked = true;
                    } else {
                      final previousPill = module.contentPills[index - 1];
                      isPillUnlocked = dayProgress?.completedPills.contains(previousPill.pillId) ?? false;
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: PillRenderer(
                        pill: pill,
                        pillContent: pill.content,
                        onValidationSuccess: () => _completePill(pill.pillId),
                        isCompleted: isPillCompleted,
                        isUnlocked: isPillUnlocked,
                      ),
                    );
                  },
                  childCount: module.contentPills.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}