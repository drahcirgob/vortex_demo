// No arquivo: lib/main.dart

import 'package:flutter/material.dart';
import 'package:vortex_demo/screens/login_screen.dart'; // Importa o arquivo da nossa futura tela de login

// A função main() é onde tudo começa.
void main() {
  runApp(const VortexApp());
}

// VortexApp é o widget principal do nosso aplicativo.
class VortexApp extends StatelessWidget {
  const VortexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vórtex Demo',
      // Remove a faixa de "Debug" no canto da tela.
      debugShowCheckedModeBanner: false,
      // Define a tela inicial do nosso aplicativo.
      // Por enquanto, será a tela de login.
      home: LoginScreen(),
    );
  }
}