// No arquivo: lib/widgets/audio_player_widget.dart

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({super.key, required this.audioUrl});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration? _duration;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    // Não faz nada se a URL estiver vazia.
    if (widget.audioUrl.isEmpty) return;

    try {
      // TODO: Na Fase 5, vamos converter a URL gs:// para HTTPS aqui.
      // Por enquanto, isso pode não funcionar na web, mas a UI aparecerá.
      await _player.setUrl(widget.audioUrl);

      _player.playerStateStream.listen((state) {
        if (mounted) setState(() => _isPlaying = state.playing);
      });

      _player.durationStream.listen((duration) {
        if (mounted) setState(() => _duration = duration);
      });

      _player.positionStream.listen((position) {
        if (mounted) setState(() => _position = position);
      });
    } catch (e) {
      debugPrint("Erro ao inicializar o player de áudio: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audioUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green[700]!),
        color: Colors.black,
      ),
      child: Column(
        children: [
          Text(
            '// RESUMO DA MISSÃO //',
            style: TextStyle(fontFamily: 'VT323', fontSize: 18, color: Colors.green[400]),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: Colors.green[400],
                  size: 40,
                ),
                onPressed: () {
                  if (_isPlaying) {
                    _player.pause();
                  } else {
                    _player.play();
                  }
                },
              ),
              Expanded(
                child: Slider(
                  min: 0.0,
                  max: _duration?.inMilliseconds.toDouble() ?? 1.0,
                  value: _position.inMilliseconds.toDouble().clamp(0.0, _duration?.inMilliseconds.toDouble() ?? 1.0),
                  onChanged: (value) {
                    _player.seek(Duration(milliseconds: value.toInt()));
                  },
                  activeColor: Colors.green[400],
                  inactiveColor: Colors.grey[700],
                ),
              ),
              Text(
                '${_formatDuration(_position)} / ${_formatDuration(_duration ?? Duration.zero)}',
                style: TextStyle(fontFamily: 'VT323', color: Colors.green[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}