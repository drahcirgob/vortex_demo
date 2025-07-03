// No arquivo: lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:vortex_demo/models/module_model.dart';
import 'package:vortex_demo/screens/module_screen.dart';
import 'package:vortex_demo/services/firestore_service.dart';
import 'package:vortex_demo/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  
  late Future<(List<Module>, UserProgress?)> _dashboardDataFuture;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;
    _dashboardDataFuture = _loadDashboardData();
    // Usamos um pequeno atraso para garantir que a tela seja construída antes de mostrar o diálogo.
    WidgetsBinding.instance.addPostFrameCallback((_) => _showWelcomeDialogIfNeeded());
  }

  Future<(List<Module>, UserProgress?)> _loadDashboardData() async {
    if (_currentUser == null) {
      throw Exception("Usuário não autenticado.");
    }
    final modules = await _firestoreService.getModules();
    final userProgress = await _firestoreService.getUserProgress(_currentUser!.uid);
    return (modules, userProgress);
  }

  /// Mostra o pop-up de boas-vindas se o usuário for novo.
  Future<void> _showWelcomeDialogIfNeeded() async {
    // Espera os dados do dashboard serem carregados.
    final userProgress = (await _dashboardDataFuture).$2;
    
    // Mostra o diálogo apenas se o usuário existir e o campo 'hasSeenWelcome' for falso.
    if (userProgress != null && !(userProgress.hasSeenWelcome ?? false)) {
      showDialog(
        context: context,
        barrierDismissible: false, // O usuário não pode fechar clicando fora.
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(side: BorderSide(color: Colors.green[400]!)),
          title: const Text('// PROTOCOLO DE IMERSÃO //', style: TextStyle(fontFamily: 'VT323', color: Colors.green)),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bem vindo. Hoje você deixa de ser um mero passageiro e assume o cockpit.', style: TextStyle(color: Colors.white)),
                SizedBox(height: 16),
                Text('Regra n°1: O cronômetro é sagrado.', style: TextStyle(color: Colors.amber)),
                Text('Cada bloco tem um início e um fim. A sua capacidade de respeitar estes limites é o primeiro passo para a disciplina profissional.', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 8),
                Text('Regra n°2: Imersão total.', style: TextStyle(color: Colors.amber)),
                Text('Durante um bloco, o mundo exterior cessa de existir. Desligue tudo. O seu foco é a sua maior ferramenta.', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 8),
                Text('Regra n°3: Recalibração neural.', style: TextStyle(color: Colors.amber)),
                Text('As pausas são obrigatórias. Afaste-se da tela, hidrate-se. É neurociência, não preguiça.', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 8),
                Text('Regra n°4: A prova de execução.', style: TextStyle(color: Colors.amber)),
                Text('O dia só termina quando o seu trabalho está versionado e seguro no seu portfólio.', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('// ENTENDIDO. INICIAR MISSÃO. //', style: TextStyle(fontFamily: 'VT323', color: Colors.green)),
              onPressed: () {
                // Marca que o usuário viu e fecha o diálogo.
                _firestoreService.markWelcomeAsSeen(_currentUser!.uid);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('// VÓRTEX // TRILHA DE IMERSÃO', style: TextStyle(fontFamily: 'VT323', color: Colors.green, fontSize: 24)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<(List<Module>, UserProgress?)>(
        future: _dashboardDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.green[400]));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Nenhum dado encontrado.', style: TextStyle(color: Colors.white)));
          }

          final (modules, userProgress) = snapshot.data!;

          return ListView.builder(
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              
              final dayStatus = userProgress?.progress[module.id]?.status ?? 'locked';
              
              final bool isLocked = dayStatus == 'locked';
              final bool isCompleted = dayStatus == 'completed';

              Color color = isLocked ? Colors.grey[700]! : (isCompleted ? Colors.blueAccent : Colors.green);
              IconData icon = isLocked ? Icons.lock : (isCompleted ? Icons.check_circle : Icons.play_arrow);

              return Card(
                color: Colors.black,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(side: BorderSide(color: color, width: 2)),
                child: ListTile(
                  onTap: isLocked ? null : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ModuleScreen(moduleId: module.id),
                      ),
                    );
                  },
                  leading: Icon(icon, color: color),
                  title: Text(
                    '[DIA ${module.dayNumber.toString().padLeft(2, '0')}] ${module.title}',
                    style: TextStyle(fontFamily: 'VT323', fontSize: 20, color: isLocked ? Colors.grey[600] : Colors.white),
                  ),
                  subtitle: Text(
                    module.subtitle,
                    style: TextStyle(fontFamily: 'VT323', color: color),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}