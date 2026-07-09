import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 52),
              const Text(
                'TRISET',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 24),
              const CardBackFan(),
              const Spacer(),
              TextField(
                controller: _nameController,
                maxLength: 14,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: "What's your name?",
                  labelStyle:
                      const TextStyle(color: Colors.black45, letterSpacing: 1),
                  counterText: '',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                ),
              ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: filled ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: filled ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
