import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class RecordingPlayerPage extends StatefulWidget {
  final String url;
  final String title;

  const RecordingPlayerPage({super.key, required this.url, this.title = 'Recording'});

  @override
  State<RecordingPlayerPage> createState() => _RecordingPlayerPageState();
}

class _RecordingPlayerPageState extends State<RecordingPlayerPage> {
  late final AudioPlayer _player;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    try {
      await _player.setUrl(widget.url);
      await _player.play();
    } catch (e) {
      // show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading audio: $e')),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 16),
            StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              builder: (context, snapshot) {
                final state = snapshot.data;
                final playing = state?.playing ?? false;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 48,
                      icon: Icon(playing ? Icons.pause_circle : Icons.play_circle),
                      onPressed: () async {
                        if (playing) {
                          await _player.pause();
                        } else {
                          await _player.play();
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      iconSize: 36,
                      icon: const Icon(Icons.stop_circle),
                      onPressed: () async {
                        await _player.stop();
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            StreamBuilder<Duration?>(
              stream: _player.durationStream,
              builder: (context, snapDur) {
                final total = snapDur.data ?? Duration.zero;
                return StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, snapPos) {
                    final pos = snapPos.data ?? Duration.zero;
                    return Column(
                      children: [
                        Slider(
                          min: 0,
                          max: total.inMilliseconds.toDouble().clamp(1, double.infinity),
                          value: pos.inMilliseconds.toDouble().clamp(0, total.inMilliseconds.toDouble().clamp(1, double.infinity)),
                          onChanged: (v) => _player.seek(Duration(milliseconds: v.toInt())),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_format(pos)),
                            Text(_format(total)),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _format(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}
