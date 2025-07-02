// No arquivo: lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:vortex_demo/data/mock_data.dart'; // Importa nossos dados
import 'package:vortex_demo/screens/module_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Para a DEMO, teremos uma lista estática de dias.
  // No futuro, isso virá do Firestore.
  final List<Map<String, dynamic>> daySummaries = [
    {'day': 1, 'title': 'A Arte do Comando', 'status': 'unlocked'},
    {'day': 2, 'title': 'Do Prompt ao Produto', 'status': 'locked'},
    {'day': 3, 'title': 'Dados como Combustível', 'status': 'locked'},
    // Adicionaríamos os outros dias aqui
  ];

  // A lógica de gamificação agora vive aqui.
  void _unlockNextDay(int completedDay) {
    setState(() {
      // Marca o dia atual como completo
      final completedDayIndex = daySummaries.indexWhere((d) => d['day'] == completedDay);
      if (completedDayIndex != -1) {
        daySummaries[completedDayIndex]['status'] = 'completed';
      }

      // Desbloqueia o próximo dia, se houver
      final nextDayIndex = daySummaries.indexWhere((d) => d['day'] == completedDay + 1);
      if (nextDayIndex != -1) {
        daySummaries[nextDayIndex]['status'] = 'unlocked';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('// VÓRTEX // TRILHA DE IMERSÃO', style: TextStyle(fontFamily: 'VT323', color: Colors.green, fontSize: 24)),
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove a seta de "voltar" do login
      ),
      body: ListView.builder(
        itemCount: daySummaries.length,
        itemBuilder: (context, index) {
          final dayData = daySummaries[index];
          final isLocked = dayData['status'] == 'locked';
          final isCompleted = dayData['status'] == 'completed';

          Color color = isLocked ? Colors.grey[700]! : (isCompleted ? Colors.blueAccent : Colors.green);
          IconData icon = isLocked ? Icons.lock : (isCompleted ? Icons.check_circle : Icons.play_arrow);

          return Card(
            color: Colors.black,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(side: BorderSide(color: color, width: 2)),
            child: ListTile(
              onTap: isLocked ? null : () {
                // Navega para a tela do módulo, passando o objeto de dados do dia correto
                // e a função para ser chamada quando o dia for concluído.
                // Por enquanto, todos levam para o mock do Dia 1.
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ModuleScreen(day: mockDay1),
                  ),
                );
              },
              leading: Icon(icon, color: color),
              title: Text(
                '[DIA ${dayData['day'].toString().padLeft(2, '0')}] ${dayData['title']}',
                style: TextStyle(fontFamily: 'VT323', fontSize: 20, color: isLocked ? Colors.grey[600] : Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}