import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mp3player/screens/index/index_screen.dart';

void main() {
  runApp(ProviderScope(
    child: const MaterialApp(
      home: MainPage(),
    ),
  ));
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const IndexPage();
  }
}
