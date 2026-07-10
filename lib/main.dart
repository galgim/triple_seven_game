import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'screens/menu_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasPlayedBefore = prefs.getBool('hasPlayedBefore') ?? false;
  final savedName = prefs.getString('playerName') ?? '';
  final theme = await AppTheme.load();
  runApp(TrisetApp(hasPlayedBefore: hasPlayedBefore, savedName: savedName, theme: theme));
}

class TrisetApp extends StatelessWidget {
  final bool hasPlayedBefore;
  final String savedName;
  final AppTheme theme;

  const TrisetApp({
    super.key,
    required this.hasPlayedBefore,
    required this.savedName,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return AppThemeScope(
      theme: theme,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
          useMaterial3: true,
        ),
        home: hasPlayedBefore
            ? MainMenuScreen(playerName: savedName)
            : const OnboardingScreen(),
      ),
    );
  }
}
