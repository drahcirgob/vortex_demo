// No arquivo: lib/data/mock_data.dart

// --- DEFINIÇÃO DA ESTRUTURA DE DADOS ---

class ContentBlock {
  final String type; // 'header', 'paragraph', 'note', 'code_block'
  final String text;
  final String? language; // Opcional, para blocos de código

  ContentBlock({required this.type, required this.text, this.language});
}

class Task {
  final String type; // 'code_validation'
  final String instruction;
  final String code;

  Task({required this.type, required this.instruction, required this.code});
}

class Pill {
  final int pillNumber;
  final String title;
  String status; // 'unlocked', 'locked', 'completed'
  final String estimatedTime;
  final List<ContentBlock> contentBlocks;
  final Task? task;

  Pill({
    required this.pillNumber,
    required this.title,
    required this.status,
    required this.estimatedTime,
    required this.contentBlocks,
    this.task,
  });
}

class Day {
  final int dayNumber;
  final String title;
  final String summary;
  final List<Pill> pills;
  // Adicionaremos o finalSummary depois

  Day({
    required this.dayNumber,
    required this.title,
    required this.summary,
    required this.pills,
  });
}

// --- DADOS FALSOS PARA O DIA 1 ---

final Day mockDay1 = Day(
  dayNumber: 1,
  title: "A Arquitetura do Comando",
  summary: "Modelos de linguagem são motores de inferência. Nós não conversamos com motores, nós os operamos.",
  pills: [
    Pill(
      pillNumber: 1,
      title: "Protocolo de Lançamento (Setup de Ambiente)",
      status: "unlocked",
      estimatedTime: "Não Cronometrado",
      contentBlocks: [
        ContentBlock(type: "note", text: "Esta seção é executada ANTES do cronômetro começar."),
        ContentBlock(type: "header", text: "O CAMINHO DOURADO: GOOGLE CLOUD SHELL"),
        ContentBlock(type: "paragraph", text: "O Google Cloud Shell é um terminal com um editor de código que roda no seu navegador."),
        ContentBlock(type: "header", text: "AÇÃO 1: ATIVAR O GOOGLE CLOUD"),
        ContentBlock(type: "paragraph", text: "Acesse o Google Cloud Console. Crie seu projeto 'ia-bootcamp-ops' e ative a Vertex AI API."),
      ],
      task: Task(
        type: "code_validation",
        instruction: "No terminal do Cloud Shell, execute os comandos para configurar seu nome e email no Git.",
        code: "git config --global user.name \"Seu Nome\"\ngit config --global user.email \"seu.email@exemplo.com\""
      )
    ),
    Pill(
      pillNumber: 2,
      title: "Bloco 1: Calibração de Comportamento",
      status: "locked",
      estimatedTime: "1.5 Horas",
      contentBlocks: [
        ContentBlock(type: "paragraph", text: "A lógica aqui é intuitiva: começamos com um prompt básico, melhoramos com uma persona e refinamos com Chain-of-Thought (CoT).")
      ],
      task: null
    ),
    Pill(
      pillNumber: 3,
      title: "Bloco 2: Construção Iterativa do Prompt Mestre",
      status: "locked",
      estimatedTime: "4 Horas",
      contentBlocks: [
        ContentBlock(type: "note", text: "Esta é a principal mudança pedagógica. Adotamos a construção passo a passo."),
        ContentBlock(type: "header", text: "ITERAÇÃO 1: A FORÇA BRUTA"),
        ContentBlock(type: "code_block", language: "prompt", text: "Analise a empresa \"NVIDIA\"..."),
      ],
      task: null
    ),
    Pill(
      pillNumber: 4,
      title: "Bloco 3: Documentação e Prova de Execução",
      status: "locked",
      estimatedTime: "1.5 Horas",
      contentBlocks: [
        ContentBlock(type: "header", text: "CHECKLIST DE ENCERRAMENTO"),
        ContentBlock(type: "paragraph", text: "1. Crie a pasta 'dia-01-prompt-architecture/'..."),
      ],
      task: Task(
        type: "code_validation",
        instruction: "Execute os comandos para adicionar, commitar e enviar seu trabalho.",
        code: "git add .\ngit commit -m \"feat(day-01): ...\"\ngit push -u origin main"
      )
    ),
  ]
);