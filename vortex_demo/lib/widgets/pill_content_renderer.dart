// No arquivo: lib/widgets/pill_content_renderer.dart

import 'package:flutter/material.dart';
import 'package:vortex_demo/data/mock_data.dart';

class PillContentRenderer extends StatelessWidget {
  final List<ContentBlock> contentBlocks;

  const PillContentRenderer({super.key, required this.contentBlocks});

  @override
  Widget build(BuildContext context) {
    // Usamos um ListView para garantir que o conteúdo seja rolável se for muito grande.
    return ListView.builder(
      shrinkWrap: true, // Impede que a lista tente ocupar um espaço infinito.
      itemCount: contentBlocks.length,
      itemBuilder: (context, index) {
        final block = contentBlocks[index];

        // Verificamos o tipo de cada bloco e aplicamos o estilo correto.
        switch (block.type) {
          case 'header':
            return Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                '// ${block.text}',
                style: const TextStyle(fontFamily: 'VT323', color: Colors.green, fontSize: 18),
              ),
            );
          case 'note':
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '# ${block.text}',
                style: TextStyle(fontFamily: 'VT323', color: Colors.grey[400], fontSize: 16, fontStyle: FontStyle.italic),
              ),
            );
          case 'code_block':
            return Container(
              color: Colors.grey[850],
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              width: double.infinity,
              child: Text(
                block.text,
                style: const TextStyle(fontFamily: 'monospace', color: Colors.white, fontSize: 14),
              ),
            );
          case 'paragraph':
          default:
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                '> ${block.text}',
                style: const TextStyle(fontFamily: 'VT323', color: Colors.white, fontSize: 16, height: 1.5),
              ),
            );
        }
      },
    );
  }
}