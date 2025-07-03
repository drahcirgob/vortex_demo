// No arquivo: lib/widgets/pill_renderer.dart

import 'package:flutter/material.dart';
import 'package:vortex_demo/models/module_model.dart';
import 'package:vortex_demo/widgets/interactive_pill_widget.dart';

class CodeBlockWidget extends StatelessWidget {
  final String code;
  final String? language;
  const CodeBlockWidget({super.key, required this.code, this.language});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      child: Text(
        code,
        style: TextStyle(
          fontFamily: 'FiraCode',
          color: Colors.cyan[300],
          fontSize: 14,
        ),
      ),
    );
  }
}

class PillRenderer extends StatelessWidget {
  final ContentPill pill;
  final VoidCallback? onValidationSuccess;
  final String? pillContent;
  final bool isCompleted;
  final bool isUnlocked;

  const PillRenderer({
    super.key,
    required this.pill,
    this.onValidationSuccess,
    this.pillContent,
    this.isCompleted = false,
    this.isUnlocked = true,
  });

  @override
  Widget build(BuildContext context) {
    // Se for interativa e já foi concluída, mostramos um feedback de sucesso.
    if (pill.validationCriteria != null && isCompleted) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: Colors.green[700]!)),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                pill.validationCriteria!.prompt,
                style: TextStyle(color: Colors.grey[600], decoration: TextDecoration.lineThrough),
              ),
            ),
          ],
        ),
      );
    }

    // Se for interativa e não foi concluída, mostramos o widget interativo.
    if (pill.validationCriteria != null) {
      return InteractivePillWidget(
        criteria: pill.validationCriteria!,
        onValidationSuccess: onValidationSuccess ?? () {},
        pillContent: pillContent ?? pill.content,
      );
    }

    // Para pílulas de conteúdo, construímos o widget e depois aplicamos o estilo.
    final contentWidget = _buildContentWidget();

    // Aplicamos o estilo de bloqueado/desbloqueado/concluído ao widget de conteúdo.
    return Opacity(
      opacity: isUnlocked ? (isCompleted ? 0.6 : 1.0) : 0.4,
      child: AbsorbPointer(
        absorbing: !isUnlocked, // Desabilita o clique se estiver bloqueado
        child: contentWidget,
      ),
    );
  }

  Widget _buildContentWidget() {
    // O switch case agora foca apenas em construir o widget correto.
    switch (pill.type) {
      case 'sectionHeader':
        return Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
          child: Text('// ${pill.title.toUpperCase()}', style: TextStyle(fontFamily: 'VT323', fontSize: 22, color: Colors.green[400])),
        );
      case 'subHeader':
        return Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
          child: Text(pill.title, style: TextStyle(fontFamily: 'VT323', fontSize: 20, color: Colors.amber[600])),
        );
      case 'paragraph':
        return Text(pill.content, style: TextStyle(color: Colors.grey[300], fontSize: 16, height: 1.5));
      case 'listItem':
        return Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('>> ', style: TextStyle(color: Colors.green[400])),
              Expanded(child: Text(pill.content, style: TextStyle(color: Colors.grey[300], fontSize: 16))),
            ],
          ),
        );
      case 'code':
        return CodeBlockWidget(code: pill.content, language: pill.language);
      case 'prompt':
        return CodeBlockWidget(code: pill.content, language: 'text');
      case 'criticalAnalysis':
        return Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(border: Border.all(color: Colors.red[400]!)),
          child: Text(pill.content, style: TextStyle(color: Colors.grey[300])),
        );
      case 'finalAssessment':
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(border: Border.all(color: Colors.yellow[400]!, width: 2)),
          child: Text(pill.content, style: TextStyle(color: Colors.grey[200], fontSize: 16, fontStyle: FontStyle.italic)),
        );
      default:
        return Text(pill.content, style: const TextStyle(color: Colors.white));
    }
  }
}