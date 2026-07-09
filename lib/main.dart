import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/menu_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasPlayedBefore = prefs.getBool('hasPlayedBefore') ?? false;
  final savedName = prefs.getString('playerName') ?? '';
  runApp(TrisetApp(hasPlayedBefore: hasPlayedBefore, savedName: savedName));
}

class TrisetApp extends StatelessWidget {
  final bool hasPlayedBefore;
  final String savedName;

  const TrisetApp({
    super.key,
    required this.hasPlayedBefore,
    required this.savedName,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: hasPlayedBefore
          ? MainMenuScreen(playerName: savedName)
          : const OnboardingScreen(),
    );
  }
}
