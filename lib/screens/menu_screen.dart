import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import '../game/game_state.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class MainMenuScreen extends StatefulWidget {
  final String playerName;

  const MainMenuScreen({super.key, this.playerName = 'You'});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  late final TextEditingController _nameController;
  bool _hasSavedGame = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.playerName);
    _checkSave();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _checkSave() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _hasSavedGame = prefs.containsKey('saved_game'));
  }

  String get _playerName {
    final trimmed = _nameController.text.trim();
    return trimmed.isEmpty ? 'You' : trimmed;
  }

  Future<void> _play() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('playerName', _playerName);
    await GameState.clearSave();
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(playerName: _playerName)),
    );
    if (mounted) _checkSave();
  }

  Future<void> _continue() async {
    final saved = await GameState.loadSave();
    if (saved == null || !mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen.fromSave(savedGame: saved)),
    );
    if (mounted) _checkSave();
  }

  void _openSettings() {
    final theme = AppThemeScope.of(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SettingsScreen(theme: theme)),
    );
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
                  labelText: 'Your name',
                  labelStyle: const TextStyle(color: Colors.black45, letterSpacing: 1),
                  counterText: '',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black26, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_hasSavedGame) ...[
                _menuButton(label: 'CONTINUE', onTap: _continue),
                const SizedBox(height: 12),
                _menuButton(label: 'NEW GAME', onTap: _play, outlined: true),
              ] else
                _menuButton(label: 'PLAY', onTap: _play),
              const SizedBox(height: 12),
              _menuButton(label: 'SETTINGS', onTap: _openSettings, outlined: true),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuButton({
    required String label,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: outlined ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: outlined ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// Public so OnboardingScreen and TutorialScreen can reuse it.
class CardBackFan extends StatelessWidget {
  const CardBackFan({super.key});

  static const double _cardW = 65.0;
  static const double _cardH = 90.0;

  Widget _backCard(Color cardBackColor) => Container(
        width: _cardW,
        height: _cardH,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black26, width: 1.5),
          boxShadow: const [
            BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(2, 3)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: BoxDecoration(
              color: cardBackColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 0.5,
                child: CustomPaint(painter: _TrianglePainter()),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final cardBackColor = AppThemeScope.of(context).cardBackColor;
    return SizedBox(
      height: 140,
      child: Center(
        child: SizedBox(
          width: 220,
          height: 140,
          child: Stack(
            children: [
              Positioned(
                left: 28,
                top: 34,
                child: Transform.rotate(angle: -0.25, child: _backCard(cardBackColor)),
              ),
              Positioned(
                right: 28,
                top: 34,
                child: Transform.rotate(angle: 0.25, child: _backCard(cardBackColor)),
              ),
              Positioned(
                left: 77,
                top: 8,
                child: _backCard(cardBackColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.16
      ..strokeJoin = StrokeJoin.round;
    final side = size.width;
    final triHeight = side * math.sqrt(3) / 2;
    final top = (size.height - triHeight) / 2;
    final path = Path()
      ..moveTo(size.width / 2, top)
      ..lineTo(size.width, top + triHeight)
      ..lineTo(0, top + triHeight)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) => false;
}
