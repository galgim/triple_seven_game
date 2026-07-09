import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_screen.dart';

class MainMenuScreen extends StatefulWidget {
  final String playerName;

  const MainMenuScreen({super.key, this.playerName = 'You'});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.playerName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String get _playerName {
    final trimmed = _nameController.text.trim();
    return trimmed.isEmpty ? 'You' : trimmed;
  }

  Future<void> _play() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('playerName', _playerName);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(playerName: _playerName),
      ),
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
              _menuButton(label: 'PLAY', onTap: _play),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.white,
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

  Widget _backCard() => Container(
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
              color: const Color(0xFF3853A4),
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
                child: Transform.rotate(angle: -0.25, child: _backCard()),
              ),
              Positioned(
                right: 28,
                top: 34,
                child: Transform.rotate(angle: 0.25, child: _backCard()),
              ),
              Positioned(
                left: 77,
                top: 8,
                child: _backCard(),
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
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) => false;
}
