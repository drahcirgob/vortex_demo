// No arquivo: lib/widgets/interactive_pill_widget.dart

import 'package:flutter/material.dart';
import 'package:vortex_demo/models/module_model.dart';
import 'package:http/http.dart' as http; // Para fazer requisições HTTP
import 'dart:convert'; // Para codificar/decodificar JSON
import 'package:flutter/foundation.dart'; // Para debugPrint

class InteractivePillWidget extends StatefulWidget {
  final ValidationCriteria criteria;
  final String pillContent; // Conteúdo da pílula para o Gemini
  final VoidCallback onValidationSuccess;

  const InteractivePillWidget({
    super.key,
    required this.criteria,
    required this.pillContent,
    required this.onValidationSuccess,
  });

  @override
  State<InteractivePillWidget> createState() => _InteractivePillWidgetState();
}

class _InteractivePillWidgetState extends State<InteractivePillWidget> {
  final TextEditingController _textController = TextEditingController();
  String? _feedbackMessage;
  bool _isValid = false;
  bool _isEvaluating = false; // Estado para feedback visual

  // --- URL DA SUA CLOUD FUNCTION ---
  static const String _cloudFunctionUrl = "https://us-central1-vortex-demo.cloudfunctions.net/evaluatePill";

  Future<void> _validateInput() async {
    if (_textController.text.isEmpty) {
      setState(() {
        _feedbackMessage = "Por favor, insira uma resposta para validar.";
        _isValid = false;
      });
      return;
    }

    setState(() {
      _isEvaluating = true; // Ativa o indicador de avaliação
      _feedbackMessage = null; // Limpa feedback anterior
    });

    try {
      final response = await http.post(
        Uri.parse(_cloudFunctionUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'data': { // Cloud Functions de 2ª geração esperam o payload dentro de 'data'
            'userInput': _textController.text,
            'validationCriteria': widget.criteria.toMap(), // Usando o novo método toMap()
            'pillContent': widget.pillContent,
          }
        }),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          setState(() {
            _isValid = responseData['isValid'] ?? false;
            _feedbackMessage = responseData['feedback'] ?? 'Sem feedback do avaliador.';
          });
          if (_isValid) {
            widget.onValidationSuccess(); // Notifica o sucesso
          }
        } else {
          setState(() {
            _isValid = false;
            _feedbackMessage = 'Erro na avaliação: ${response.statusCode}. Verifique os logs.';
          });
          debugPrint('Erro na Cloud Function: ${response.body}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValid = false;
          _feedbackMessage = 'Erro de conexão. Verifique sua internet e tente novamente.';
        });
      }
      debugPrint('Erro ao chamar Cloud Function: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isEvaluating = false; // Desativa o indicador
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber[600]!),
        color: Colors.black,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.criteria.prompt,
            style: TextStyle(color: Colors.amber[600], fontSize: 16, fontFamily: 'VT323'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            style: const TextStyle(color: Colors.white, fontFamily: 'FiraCode'),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[900],
              border: const OutlineInputBorder(borderSide: BorderSide.none),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _isEvaluating
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.amber[600]),
                      ),
                      const SizedBox(width: 16),
                      const Text('// AVALIANDO EXECUÇÃO... //', style: TextStyle(fontFamily: 'VT323')),
                    ],
                  ),
                )
              : ElevatedButton(
                  onPressed: _validateInput,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[600]),
                  child: const Text('// VALIDAR EXECUÇÃO //', style: TextStyle(color: Colors.black, fontFamily: 'VT323')),
                ),
          if (_feedbackMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                _feedbackMessage!,
                style: TextStyle(color: _isValid ? Colors.green[400] : Colors.red[400], fontFamily: 'VT323'),
              ),
            ),
        ],
      ),
    );
  }
}