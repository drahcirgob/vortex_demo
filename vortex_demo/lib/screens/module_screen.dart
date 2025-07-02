// No arquivo: lib/screens/module_screen.dart

import 'package:flutter/material.dart';
import 'package:vortex_demo/data/mock_data.dart';
import 'package:vortex_demo/widgets/pill_content_renderer.dart';

class ModuleScreen extends StatefulWidget {
  final Day day; // Agora a tela recebe o objeto 'Day' inteiro

  const ModuleScreen({super.key, required this.day});

  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  // Função para exibir o conteúdo de uma pílula em um popup (modal)
  void _showPillContent(Pill pill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(pill.title, style: const TextStyle(fontFamily: 'VT323', color: Colors.green)),
        content: SizedBox(
          width: double.maxFinite,
          child: PillContentRenderer(contentBlocks: pill.contentBlocks),
        ),
        actions: [
          // Se a pílula tiver uma tarefa, mostramos o botão de completar
          if (pill.task != null)
            TextButton(
              onPressed: () {
                _completePill(pill.pillNumber);
                Navigator.of(context).pop(); // Fecha o popup
              },
              child: const Text('// TAREFA CONCLUÍDA //', style: TextStyle(fontFamily: 'VT323', color: Colors.amber)),
            )
          else // Se não tiver tarefa, é só um botão para fechar
            TextButton(
              onPressed: () {
                _completePill(pill.pillNumber); // Marcamos como concluída mesmo assim
                Navigator.of(context).pop();
              },
              child: const Text('// ENTENDIDO //', style: TextStyle(fontFamily: 'VT323', color: Colors.green)),
            ),
        ],
      ),
    );
  }

  // A lógica de gamificação das pílulas
  void _completePill(int pillNumber) {
    setState(() {
      final completedPillIndex = widget.day.pills.indexWhere((p) => p.pillNumber == pillNumber);
      if (completedPillIndex != -1) {
        widget.day.pills[completedPillIndex].status = 'completed';
      }

      final nextPillIndex = completedPillIndex + 1;
      if (nextPillIndex < widget.day.pills.length) {
        widget.day.pills[nextPillIndex].status = 'unlocked';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.green),
        title: Text('// ${widget.day.title.toUpperCase()} //', style: const TextStyle(fontFamily: 'VT323', color: Colors.green, fontSize: 24)),
      ),
      body: ListView.builder(
        itemCount: widget.day.pills.length,
        itemBuilder: (context, index) {
          final pill = widget.day.pills[index];
          final isLocked = pill.status == 'locked';
          final isCompleted = pill.status == 'completed';

          Color color = isLocked ? Colors.grey[700]! : (isCompleted ? Colors.blueAccent : Colors.green);

          return Card(
            color: Colors.black,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(side: BorderSide(color: color, width: 2)),
            child: ListTile(
              onTap: isLocked ? null : () => _showPillContent(pill),
              leading: Icon(isLocked ? Icons.lock : (isCompleted ? Icons.check_circle : Icons.play_arrow), color: color),
              title: Text(pill.title, style: TextStyle(fontFamily: 'VT323', fontSize: 20, color: isLocked ? Colors.grey[600] : Colors.white)),
              subtitle: Text(pill.estimatedTime, style: TextStyle(fontFamily: 'VT323', color: color)),
            ),
          );
        },
      ),
    );
  }
}