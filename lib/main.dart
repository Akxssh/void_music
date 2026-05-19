import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:void_music/pages/add.dart';
import 'package:void_music/pages/player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
      builder: (context, child) => FTheme(
        data: FThemes.zinc.light.desktop,
        child: FToaster(child: child!),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Widget> _pages = [Player(), Add()];
  var _currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        onTap: (i) => setState(() {
          _currentPageIndex = i;
        }),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.headphones_rounded),
            label: "Player",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_add),
            label: "Library",
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: context.theme.colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.graphic_eq_rounded,
              color: context.theme.colors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'void',
              style: TextStyle(
                color: context.theme.colors.foreground,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'music',
              style: TextStyle(
                color: context.theme.colors.mutedForeground,
                fontSize: 20,
                fontWeight: FontWeight.w300,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: context.theme.colors.border,
          ),
        ),
      ),
      body: _pages[_currentPageIndex],
    );
  }
}
