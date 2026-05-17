import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Add extends StatefulWidget {
  const Add({super.key});
  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  List<String> _songs = [];

  void _showToast() {
    showFToast(
      context: context,
      title: const Text("Button pressed!"),
      description: const Text("just a description thats unnesecirily long."),
      alignment: FToastAlignment.topCenter,
      swipeToDismiss: const [AxisDirection.right, AxisDirection.left],
      duration: const Duration(milliseconds: 700),
    );
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );
    if (result == null) {
      showFToast(context: context, title: const Text('canceled adding song'));
      return;
    }
    // final songPath = result.files.first.path;
    // final songName = result.files.single.name;
    setState(() {
      for (final file in result.files) {
        _songs.add(file.path!);
      }
    });
    _showSongAddedToast(result.files.length);
  }

  Future<void> _saveFiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('songs', _songs);
  }

  Future<void> _loadFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('songs');
    setState(() {
      _songs = data ?? [];
    });
  }

  _showSongAddedToast(songName) {
    if (mounted) {
      showFToast(
        context: context,
        title: const Text('Song added!'),
        description: Text('$songName Songs were added.'),
        alignment: FToastAlignment.topCenter,
      );
    }
  }

  Future<void> _handleAddButton() async {
    await _pickFiles();
    await _saveFiles();
  }

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  void _handleDeleteSongAtIndex(int index) {
    showFDialog(
      context: context,
      builder: (context, style, animation) => FDialog(
        style: style,
        animation: animation,
        direction: .horizontal,
        title: const Text('Are you absolutely sure?'),
        body: const Text(
          'This action cannot be undone. This will permanently delete your account and '
          'remove your data from our servers.',
        ),
        actions: [
          FButton(
            size: .sm,
            child: const Text('Continue'),
            onPress: () {
              setState(() {
                _songs.removeAt(index);
              });
              _saveFiles();
              Navigator.of(context).pop();
            },
          ),
          FButton(
            variant: .outline,
            size: .sm,
            child: const Text('Cancel'),
            onPress: () {
              showFToast(
                context: context,
                title: const Text("cancled deletion"),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: GestureDetector(
        onTap: _handleAddButton,
        child: Container(
          width: 150,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFF18181A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: FButton(
              onPress: null,
              child: Row(
                children: [
                  const Text(
                    "Add songs",
                    style: TextStyle(color: Colors.white),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      CupertinoIcons.plus,
                      color: Colors.white,
                      size: 16 * 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          // const Text("Add page"),
          Expanded(
            child: ListView.builder(
              itemCount: _songs.length,
              itemBuilder: (BuildContext context, int index) {
                final songPath = _songs[index];
                final songName = songPath.split('/').last;
                final displayName = songName.length > 25
                    ? '${songName.substring(0, 25)}...'
                    : songName;

                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: FCard(
                    title: Row(
                      children: [
                        Text('${index + 1}: '),
                        Expanded(
                          child: Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        FButton(
                          onPress: () => _handleDeleteSongAtIndex(index),
                          variant: .destructive,
                          child: const Text("delete"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
