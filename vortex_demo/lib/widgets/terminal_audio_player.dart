// No arquivo: lib/widgets/terminal_audio_player.dart

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class TerminalAudioPlayer extends StatefulWidget {
  final String audioPath;
  const TerminalAudioPlayer({super.key, required this.audioPath});

  @override
  State<TerminalAudioPlayer> createState() => _TerminalAudioPlayerState();
}

class _TerminalAudioPlayerState extends State<TerminalAudioPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Prepara o player com o nosso arquivo de áudio local.
    _audioPlayer.setAsset(widget.audioPath);
    _audioPlayer.playingStream.listen((playing) {
      setState(() => _isPlaying = playing);
    });
  }

  @override
  void dispose() {
    // Libera os recursos do player quando a tela é destruída. Crucial!
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green[700]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
            color: Colors.green,
            iconSize: 40,
            onPressed: () {
              _isPlaying ? _audioPlayer.pause() : _audioPlayer.play();
            },
          ),
          const SizedBox(width: 16),
          const Text(
            '// SÍNTESE ESTRATÉGICA //',
            style: TextStyle(fontFamily: 'VT323', color: Colors.green, fontSize: 18),
          )
        ],
      ),
    );
  }
}