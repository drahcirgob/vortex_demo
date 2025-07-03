// No arquivo: lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importamos o User do Firebase
import 'package:vortex_demo/screens/dashboard_screen.dart'; // Navegação para o dashboard
import 'package:vortex_demo/services/auth_service.dart';
import 'package:flutter/foundation.dart';

// Convertido para StatefulWidget para gerenciar o estado de carregamento.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Instância do nosso serviço de autenticação.
  final AuthService _authService = AuthService();
  // Variável para controlar a exibição do indicador de progresso.
  bool _isLoading = false;

  // Função que lida com a lógica do clique no botão.
  Future<void> _handleSignIn() async {
    // 1. Ativa o estado de carregamento e reconstrói a UI.
    setState(() {
      _isLoading = true;
    });

    // 2. Chama o nosso serviço de autenticação.
    final User? user = await _authService.signInWithGoogle();

    // 3. Desativa o estado de carregamento.
    // O 'if (mounted)' é uma verificação de segurança para garantir que o widget
    // ainda está na árvore de widgets antes de chamar setState.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    // 4. Verifica o resultado e navega ou mostra erro.
    if (user != null) {
      debugPrint("Login bem-sucedido: ${user.displayName}");
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } else {
      debugPrint("Falha no login ou usuário cancelou.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[700],
            content: const Text(
              'Falha ao realizar o login. Tente novamente.',
              style: TextStyle(fontFamily: 'VT323'),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '> VÓRTEX TERMINAL ONLINE.\n> AGUARDANDO AUTENTICAÇÃO...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green[400],
                fontSize: 22,
                fontFamily: 'VT323',
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.green.withAlpha(128),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            // Lógica condicional: Se estiver carregando, mostra um indicador de progresso.
            // Senão, mostra o botão.
            _isLoading
                ? CircularProgressIndicator(
                    color: Colors.green[400],
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[400],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      side: BorderSide(color: Colors.green[700]!),
                    ),
                    // A ação onPressed agora chama nossa função de lógica.
                    onPressed: _handleSignIn,
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