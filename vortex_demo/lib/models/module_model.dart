// No arquivo: lib/models/module_model.dart

class ValidationCriteria {
  final String prompt;
  final String type;
  final dynamic values;
  final dynamic pattern;
  final num? min;
  final num? max;
  final String? value;

  ValidationCriteria({
    required this.prompt,
    required this.type,
    this.values,
    this.pattern,
    this.min,
    this.max,
    this.value,
  });

  factory ValidationCriteria.fromMap(Map<String, dynamic> map) {
    return ValidationCriteria(
      prompt: map['prompt'] ?? 'Valide sua resposta:',
      type: map['type'] ?? 'unknown',
      values: map['values'],
      pattern: map['pattern'],
      min: map['min'],
      max: map['max'],
      value: map['value'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prompt': prompt,
      'type': type,
      'values': values,
      'pattern': pattern,
      'min': min,
      'max': max,
      'value': value,
    };
  }
}

class ContentPill {
  final String pillId;
  final String title;
  final String type;
  final String content;
  final String? language;
  final ValidationCriteria? validationCriteria;

  ContentPill({
    required this.pillId,
    required this.title,
    required this.type,
    required this.content,
    this.language,
    this.validationCriteria,
  });

  factory ContentPill.fromMap(Map<String, dynamic> map) {
    return ContentPill(
      pillId: map['pillId'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? 'paragraph',
      content: map['content'] ?? '',
      language: map['language'],
      validationCriteria: map['validationCriteria'] != null
          ? ValidationCriteria.fromMap(map['validationCriteria'])
          : null,
    );
  }
}

class Module {
  final String id;
  final int dayNumber;
  final String title;
  final String subtitle;
  final String audioSummaryUrl;
  final List<ContentPill> contentPills;

  Module({
    required this.id,
    required this.dayNumber,
    required this.title,
    required this.subtitle,
    required this.audioSummaryUrl,
    required this.contentPills,
  });

  factory Module.fromMap(String id, Map<String, dynamic> map) {
    return Module(
      id: id,
      dayNumber: map['dayNumber'] ?? 0,
      title: map['title'] ?? 'Título Indisponível',
      subtitle: map['subtitle'] ?? '',
      audioSummaryUrl: map['audioSummaryUrl'] ?? '',
      contentPills: (map['contentPills'] as List<dynamic>?)
              ?.map((pillMap) => ContentPill.fromMap(pillMap as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// --- NOVAS CLASSES PARA O PROGRESSO DO USUÁRIO ---

/// Representa o status de um único dia para um usuário.
class DayProgress {
  final String status; // 'locked', 'unlocked', 'completed'
  final List<String> completedPills; // Lista de pillIds concluídos

  DayProgress({required this.status, required this.completedPills});

  factory DayProgress.fromMap(Map<String, dynamic> map) {
    return DayProgress(
      status: map['status'] ?? 'locked',
      // Garante que a lista seja do tipo correto (List<String>)
      completedPills: List<String>.from(map['completedPills'] ?? []),
    );
  }
}

/// Representa o progresso completo de um usuário no bootcamp.
class UserProgress {
  final String uid;
  final String email;
  final String displayName;
  // Um mapa onde a chave é o ID do módulo (ex: 'dia-01') e o valor é o progresso daquele dia.
  final Map<String, DayProgress> progress;
  final bool? hasSeenWelcome;

  UserProgress({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.progress,
    this.hasSeenWelcome,
  });

  factory UserProgress.fromMap(String uid, Map<String, dynamic> map) {
    // Converte o mapa de progresso do Firestore para o nosso objeto DayProgress.
    final progressData = map['progress'] as Map<String, dynamic>? ?? {};
    final Map<String, DayProgress> progressMap = progressData.map(
      (key, value) => MapEntry(
        key,
        DayProgress.fromMap(value as Map<String, dynamic>),
      ),
    );

    return UserProgress(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'Operador Anônimo',
      progress: progressMap,
    );
  }
}