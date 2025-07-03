// No arquivo: lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:vortex_demo/services/firestore_service.dart'; // Importamos o FirestoreService

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  // --- NOVA ADIÇÃO: Instância do FirestoreService ---
  final FirestoreService _firestoreService = FirestoreService();

  // --- MÉTODO PRIVADO DE ONBOARDING ---
  /// Garante que um registro de progresso exista para o usuário.
  /// Chamado após qualquer método de login/registro bem-sucedido.
  Future<void> _ensureUserData(User user) async {
    await _firestoreService.checkAndCreateUser(
      user.uid,
      user.email ?? 'no-email@vortex.com',
      user.displayName ?? 'Operador Anônimo',
    );
  }

  // --- MÉTODOS DE E-MAIL E SENHA ---

  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;

      // --- INTEGRAÇÃO DO PROGRESSO ---
      if (user != null) {
        await _ensureUserData(user); // Garante a criação do progresso
        debugPrint("Usuário registrado e progresso criado para: ${user.email}");
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        debugPrint('A senha fornecida é muito fraca.');
      } else if (e.code == 'email-already-in-use') {
        debugPrint('Já existe uma conta para este e-mail.');
      } else {
        debugPrint("Erro de registro do Firebase: ${e.code} - ${e.message}");
      }
      return null;
    } catch (e) {
      debugPrint("Um erro inesperado ocorreu no registro: $e");
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;

      // --- INTEGRAÇÃO DO PROGRESSO ---
      if (user != null) {
        await _ensureUserData(user); // Garante a verificação/criação do progresso
        debugPrint("Usuário logado e progresso verificado para: ${user.email}");
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        debugPrint('Credenciais inválidas. Verifique o e-mail e a senha.');
      } else {
        debugPrint("Erro de login do Firebase: ${e.code} - ${e.message}");
      }
      return null;
    } catch (e) {
      debugPrint("Um erro inesperado ocorreu no login: $e");
      return null;
    }
  }

  // --- MÉTODO DO GOOGLE ---
  
  Future<User?> signInWithGoogle() async {
    // A verificação kIsWeb direciona para a implementação correta
    if (kIsWeb) {
      return _signInWithGoogleForWeb();
    } else {
      return _signInWithGoogleForMobile();
    }
  }

  // Implementação para WEB (Funcional)
  Future<User?> _signInWithGoogleForWeb() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
      final User? user = userCredential.user;

      // --- INTEGRAÇÃO DO PROGRESSO ---
      if (user != null) {
        await _ensureUserData(user); // Garante a verificação/criação do progresso
        debugPrint("Login (Web) com Google bem-sucedido e progresso verificado para: ${user.displayName}");
      }

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Erro de login com Google (Web): ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      debugPrint("Erro inesperado no login com Google (Web): $e");
      return null;
    }
  }
  
  Future<User?> _signInWithGoogleForMobile() async {
    debugPrint("Login para Mobile não é suportado nesta configuração de projeto.");
    return null;
  }

  // --- MÉTODOS GERAIS ---

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      debugPrint("Usuário desconectado.");
    } catch (e) {
      debugPrint("Erro ao fazer signOut: $e");
    }
  }

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}