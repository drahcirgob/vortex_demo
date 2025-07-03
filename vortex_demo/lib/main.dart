// No arquivo: lib/main.dart

import 'package:flutter/material.dart';
import 'firebase_options.dart'; // Importa as configurações do seu projeto (gerado pelo flutterfire configure)

// Importa as telas da sua aplflufficação
import 'package:vortex_demo/screens/login_screen.dart';
import 'package:vortex_demo/screens/dashboard_screen.dart';

// A função principal da aplicação. Ela é assíncrona para permitir a inicialização do Firebase.
void main() async {
  // Garante que os widgets do Flutter estejam inicializados antes de qualquer operação Firebase.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com as opções específicas da plataforma (web, Android, iOS, etc.).
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicia a execução da aplicação Flutter.
  runApp(const MyApp());
}

class Firebase {
  static Future<void> initializeApp({required FirebaseOptions options}) async {}
}

// A classe raiz da sua aplicação Flutter.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vórtex', // Título da aplicação (aparece na aba do navegador, por exemplo)
      debugShowCheckedModeBanner: false, // Remove a faixa de "Debug" no canto superior direito

      // Define o tema visual da aplicação
      theme: ThemeData(
        brightness: Brightness.dark, // Tema escuro
        primarySwatch: Colors.green, // Cor primária para widgets Material Design
        fontFamily: 'VT323', // Define a fonte padrão para toda a aplicação
        // Você pode adicionar mais configurações de tema aqui, como textTheme, colorScheme, etc.
      ),

      // Define a rota inicial da aplicação.
      // A tela de login será a primeira a ser exibida.
      initialRoute: '/',

      // Define as rotas nomeadas da aplicação.
      // Isso permite navegar entre as telas usando nomes (ex: Navigator.pushNamed('/dashboard')).
      routes: {
        '/': (context) => const LoginScreen(), // Rota raiz para a tela de Login
        '/dashboard': (context) => const DashboardScreen(), // Rota para a tela do Dashboard
      },
    );
  }
}