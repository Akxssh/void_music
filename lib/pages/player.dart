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
  Future<void> _loadFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('songs');
    setState(() {
      _songs = data ?? [];
    });
  }

  Future<void> _playSong() async {
    try {
      await player.setFilePath(
        r"C:\Users\notno\Downloads\【OSHI NO KO】 Season 2 Non-Credit Opening GEMN “Fatale”.mp3",
      );

      await player.play();

      debugPrint("playing");
    } catch (e) {
      debugPrint("ERROR: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFiles();
    _playSong();
    debugPrint("ran func");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: _songs.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: FCard(
              child: Text(p.basenameWithoutExtension(_songs[index])),
            ),
          );
        },
      ),
    );
  }
}
