import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_button.dart';
import '../widgets/name_field.dart';
import '../widgets/triset_title.dart';
import 'menu_screen.dart';
import 'tutorial_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String get _name {
    final t = _nameController.text.trim();
    return t.isEmpty ? 'You' : t;
  }

  Future<void> _saveAndGo({required bool firstTime}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('playerName', _name);
    await prefs.setBool('hasPlayedBefore', true);
    if (!mounted) return;
    if (firstTime) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TutorialScreen(playerName: _name),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainMenuScreen(playerName: _name),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 52),
              const TrisetTitle(),
              const SizedBox(height: 24),
              const CardBackFan(),
              const SizedBox(height: 40),
              NameField(controller: _nameController, labelText: "What's your name?"),
              const SizedBox(height: 28),
              const Text(
                'Is this your first time\nplaying Triset?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _choiceButton(
                      'YES — SHOW ME',
                      filled: true,
                      onTap: () => _saveAndGo(firstTime: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _choiceButton(
                      "NO — LET'S GO",
                      filled: false,
                      onTap: () => _saveAndGo(firstTime: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _choiceButton(String label,
      {required bool filled, required VoidCallback onTap}) {
    return AppButton(
      label: label,
      onTap: onTap,
      backgroundColor: filled ? Colors.black : Colors.white,
      textColor: filled ? Colors.white : Colors.black,
      borderColor: Colors.black,
      verticalPadding: 16,
      fontSize: 13,
      letterSpacing: 1.5,
    );
  }
}
