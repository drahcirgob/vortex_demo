// No arquivo: lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // NOVA IMPORTAÇÃO
import 'package:vortex_demo/models/module_model.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // --- NOVA ADIÇÃO: Instância do Firebase Storage ---
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');

  /// Busca todos os módulos do bootcamp no Firestore, exceto o Dia 0.
  Future<List<Module>> getModules() async {
    try {
      final snapshot = await _db
          .collection('modules')
          .where('dayNumber', isGreaterThan: 0)
          .orderBy('dayNumber')
          .get();

      final modules = snapshot.docs.map((doc) {
        return Module.fromMap(doc.id, doc.data());
      }).toList();
      return modules;
    } catch (e) {
      debugPrint("Erro ao buscar módulos: $e");
      return <Module>[];
    }
  }

  /// Busca um único módulo e converte a URL do áudio para uma URL de download HTTPS.
  Future<Module> getModuleById(String moduleId) async {
    try {
      final docSnapshot = await _db.collection('modules').doc(moduleId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        String httpsAudioUrl = '';

        // Se existir uma URL gs://, tenta obter a URL de download.
        if (data['audioSummaryUrl'] != null && data['audioSummaryUrl'].isNotEmpty) {
          try {
            // --- LÓGICA CRÍTICA DE CONVERSÃO ---
            httpsAudioUrl = await _storage.refFromURL(data['audioSummaryUrl']).getDownloadURL();
          } catch (e) {
            debugPrint("Erro ao obter URL de download para ${data['audioSummaryUrl']}: $e");
            // Deixa a URL vazia se houver erro, para o player não tentar tocar.
          }
        }
        
        // Cria uma cópia mutável do mapa de dados para atualizar a URL.
        final updatedData = Map<String, dynamic>.from(data);
        updatedData['audioSummaryUrl'] = httpsAudioUrl;

        return Module.fromMap(docSnapshot.id, updatedData);
      } else {
        throw Exception("Módulo com ID $moduleId não encontrado.");
      }
    } catch (e) {
      debugPrint("Erro ao buscar módulo por ID: $e");
      rethrow;
    }
  }

  Future<void> checkAndCreateUser(String uid, String email, String displayName) async {
    final userDocRef = _usersCollection.doc(uid);
    final userDoc = await userDocRef.get();

    if (!userDoc.exists) {
      debugPrint("Novo usuário detectado. Criando registro de progresso para $uid...");
      await userDocRef.set({
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'hasSeenWelcome': false,
        'progress': {
          'dia-01': {'status': 'unlocked', 'completedPills': []},
          'dia-02': {'status': 'locked', 'completedPills': []},
          'dia-03': {'status': 'locked', 'completedPills': []},
          'dia-04': {'status': 'locked', 'completedPills': []},
          'dia-05': {'status': 'locked', 'completedPills': []},
          'dia-06': {'status': 'locked', 'completedPills': []},
          'dia-07': {'status': 'locked', 'completedPills': []},
          'dia-08': {'status': 'locked', 'completedPills': []},
          'dia-09': {'status': 'locked', 'completedPills': []},
          'dia-10': {'status': 'locked', 'completedPills': []},
        },
      });
    } else {
      debugPrint("Usuário existente $uid. Nenhum registro de progresso criado.");
    }
  }

  Future<UserProgress?> getUserProgress(String uid) async {
    try {
      final docSnapshot = await _usersCollection.doc(uid).get();
      if (docSnapshot.exists) {
        return UserProgress.fromMap(uid, docSnapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint("Erro ao buscar progresso do usuário: $e");
      return null;
    }
  }

  Future<void> updatePillCompletion(String uid, String dayId, String pillId) async {
    try {
      final userDocRef = _usersCollection.doc(uid);
      await userDocRef.update({
        'progress.$dayId.completedPills': FieldValue.arrayUnion([pillId])
      });
      debugPrint("Progresso da pílula $pillId para o dia $dayId atualizado para o usuário $uid.");
    } catch (e) {
      debugPrint("Erro ao atualizar progresso da pílula: $e");
    }
  }

  Future<void> updateDayStatus(String uid, String dayId, String status) async {
    try {
      final userDocRef = _usersCollection.doc(uid);
      await userDocRef.update({
        'progress.$dayId.status': status
      });
      debugPrint("Status do dia $dayId atualizado para '$status' para o usuário $uid.");
    } catch (e) {
      debugPrint("Erro ao atualizar status do dia: $e");
    }
  }

  Future<void> markWelcomeAsSeen(String uid) async {
    try {
      await _usersCollection.doc(uid).update({'hasSeenWelcome': true});
    } catch (e) {
      debugPrint("Erro ao marcar boas-vindas como visto: $e");
    }
  }
}