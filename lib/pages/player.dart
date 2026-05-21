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
  String? _currentSong;

  Future<void> _loadFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('songs');
    setState(() {
      _songs = data ?? [];
    });
  }

  Future<void> _playSong(String songPath) async {
    try {
      String cleanPath = Uri.decodeFull(songPath);
      await player.stop();
      await player.setFilePath(cleanPath);
      await player.play();
      setState(() => _currentSong = songPath);
      if (mounted) {
        showFToast(
          context: context,
          title: Text('Now playing: ${p.basenameWithoutExtension(songPath)}'),
        );
      }
    } catch (e) {
      debugPrint("ERROR: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _songs.length,
      itemBuilder: (context, index) {
        final songName = p.basenameWithoutExtension(_songs[index]);
        final displayName = songName.length > 35
            ? '${songName.substring(0, 35)}...'
            : songName;
        final isPlaying = _currentSong == _songs[index];

        return Padding(
          padding: const EdgeInsets.all(4.0),
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
    );
  }
}
