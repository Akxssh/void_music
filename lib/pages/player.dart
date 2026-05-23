import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

class Player extends StatefulWidget {
  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  final player = AudioPlayer();
  List<String> _songs = [];
  String? currentSong;

  Future<void> _loadFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('songs');
    setState(() {
      _songs = data ?? [];
    });
  }

  Future<void> _togglePlayPause() async {
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }

    setState(() {});
  }

  Future<void> _playSong(String songPath) async {
    try {
      final cleanPath = Uri.decodeFull(songPath);
      await player.stop();
      await player.setFilePath(cleanPath);
      await player.play();
      setState(() => currentSong = songPath);
      if (mounted) {
        showFToast(
          context: context,
          title: Text('Now playing: ${p.basenameWithoutExtension(cleanPath)}'),
        );
      }
    } catch (e, st) {
      final err = e.toString();
      debugPrint("ERROR: $err\n$st");
      // Detect common messages for invalid/illegal characters in file paths/URIs
      final lower = err.toLowerCase();
      if (lower.contains('Filename') ||
          lower.contains('contains') ||
          lower.contains('uri') ||
          lower.contains('unexpected')) {
        showFToast(
          context: context,
          title: Text('Filename contains illegal/incompatible characters'),
        );
        _playNext();
      } else {
        showFToast(context: context, title: Text(err));
      }
    }
  }

  void _playNext() {
    if (_songs.isEmpty || currentSong == null) return;
    final currentIndex = _songs.indexOf(currentSong!);
    final nextIndex = (currentIndex + 1) % _songs.length; // loops back to start
    _playSong(_songs[nextIndex]);
  }

  @override
  void initState() {
    super.initState();
    _loadFiles();
    // Listen for completion to play next song
    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playNext();
      }
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      bottomSheet: BottomPlayer(),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: ListView.builder(
          itemCount: _songs.length,
          itemBuilder: (context, index) {
            final songName = p.basenameWithoutExtension(_songs[index]);
            final displayName = songName.length > 35
                ? '${songName.substring(0, 35)}...'
                : songName;
            final isPlaying = currentSong == _songs[index];

            return Padding(
              padding: const EdgeInsets.only(
                top: 4.0,
                left: 2,
                right: 2,
                bottom: 2,
              ),
              child: FCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${index + 1}: $displayName',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: isPlaying
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    FButton(
                      onPress: () => _playSong(_songs[index]),
                      child: Text(isPlaying ? "Playing" : "Play"),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
    return scaffold;
  }
}

class BottomPlayer extends StatefulWidget {
  const BottomPlayer({Key? key}) : super(key: key);

  @override
  _BottomPlayerState createState() => _BottomPlayerState();
}

class _BottomPlayerState extends State<BottomPlayer> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: const Center(child: Text("No song playing")),
    );
  }
}
