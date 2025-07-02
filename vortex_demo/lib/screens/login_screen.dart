// No arquivo: lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:vortex_demo/screens/dashboard_screen.dart'; // Importamos o dashboard para a navegação

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        // Usamos uma Coluna para empilhar o texto e o botão verticalmente
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centraliza a coluna na vertical
          children: [
            // O texto do nosso terminal
            Text(
              '> VÓRTEX TERMINAL ONLINE.\n> AGUARDANDO AUTENTICAÇÃO...',
              textAlign: TextAlign.center, // Centraliza o texto de múltiplas linhas
              style: TextStyle(
                color: Colors.green[400], // Cor verde "fósforo"
                fontSize: 22,
                fontFamily: 'VT323', // A FONTE QUE ADICIONAMOS!
                shadows: [ // Adiciona um brilho sutil para o efeito de monitor
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.green.withOpacity(0.5),
                  ),
                ],
              ),
            ),
            // Um espaço vertical entre o texto e o botão
            const SizedBox(height: 50),
            // Nosso botão, agora estilizado
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400], // Fundo do botão verde
                foregroundColor: Colors.black, // Cor do texto do botão
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0), // Bordas retas
                ),
                side: BorderSide(color: Colors.green[700]!), // Borda sutil
              ),
              // A ação de navegação
              onPressed: () {
                // Navega para a tela do Dashboard, substituindo a tela de login.
                // O usuário não poderá "voltar" para o login.
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                );
              },
              child: const Text(
                '// INICIAR SESSÃO //',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'VT323',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}