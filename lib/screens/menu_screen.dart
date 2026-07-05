import 'package:flutter/material.dart';
import 'game_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'You');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String get _playerName {
    final trimmed = _nameController.text.trim();
    return trimmed.isEmpty ? 'You' : trimmed;
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
                'TRIPLE\nSEVEN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 24),
              const _CardBackFan(),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              _menuButton(
                context,
                label: 'PLAY',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(playerName: _playerName),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _menuButton(
                context,
                label: 'HOW TO PLAY',
                filled: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HowToPlayScreen()),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context,
      {required String label, required VoidCallback onTap, bool filled = true}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: filled ? Colors.black : Colors.white,
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
              color: filled ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class _CardBackFan extends StatelessWidget {
  const _CardBackFan();

  static const double _cardW = 65.0;
  static const double _cardH = 90.0;

  Widget _backCard() => Container(
        width: _cardW,
        height: _cardH,
        decoration: BoxDecoration(
          color: const Color(0xFF003087),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black26, width: 1.5),
          boxShadow: const [
            BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(2, 3)),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const Center(
              child: Text(
                '777',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
            ),
          ],
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

class _DecorativeFan extends StatelessWidget {
  const _DecorativeFan();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(
        child: SizedBox(
          width: 180,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 8,
                top: 22,
                child: Transform.rotate(angle: -0.35, child: _card()),
              ),
              Positioned(
                left: 64,
                top: 6,
                child: _card(),
              ),
              Positioned(
                right: 8,
                top: 22,
                child: Transform.rotate(angle: 0.35, child: _card()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card() => Container(
        width: 52,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.black, width: 1.5),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(1, 2)),
          ],
        ),
        child: const Center(
          child: Text(
            '7',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
        ),
      );
}

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('HOW TO PLAY',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RuleSection(
              title: '🎯 GOAL',
              body:
                  'Be the first player to collect 3 sets of matching cards. A set is 3 cards with the same number.',
            ),
            _RuleSection(
              title: '🃏 THE DECK',
              body:
                  'The deck has cards numbered 1 to 12, with 3 copies of each number — 36 cards total.',
            ),
            _RuleSection(
              title: '🔀 SETUP',
              body:
                  'Each player is dealt 9 cards face down. The remaining 9 cards form the middle pile.',
            ),
            _RuleSection(
              title: '▶ YOUR TURN',
              body:
                  'On your turn you can either:\n\n• Take the HIGHEST card from another player\n• Take the LOWEST card from another player\n• Pick a random card from the middle pile\n\nThe card is revealed immediately when taken.',
            ),
            _RuleSection(
              title: '✅ SETS',
              body:
                  'When you have 3 cards with the same number they automatically form a set and are removed from your hand.',
            ),
            _RuleSection(
              title: '🏆 WINNING',
              body: 'The first player to collect 3 sets wins the game!',
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleSection extends StatelessWidget {
  final String title;
  final String body;

  const _RuleSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87)),
          const Divider(height: 32, color: Colors.black12),
        ],
      ),
    );
  }
}
