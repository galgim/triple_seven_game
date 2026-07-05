import 'package:flutter/material.dart';
import 'screens/menu_screen.dart';

void main() {
  runApp(const TripleSevenApp());
}

class TripleSevenApp extends StatelessWidget {
  const TripleSevenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}
