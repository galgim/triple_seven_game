import 'package:flutter/material.dart';
import '../widgets/app_button.dart';
import 'game_screen.dart';
import 'menu_screen.dart';

class TutorialScreen extends StatefulWidget {
  final String? playerName;
  final bool reviewOnly;

  const TutorialScreen({super.key, this.playerName, this.reviewOnly = false});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _step = 0;

  static const _slides = [
    _Slide(
      title: 'Welcome!',
      body:
          "You're playing against two AI opponents. Your goal is simple — collect 3 matching sets of cards before they do.",
      illustration: _IllType.logo,
    ),
    _Slide(
      title: 'The Deck',
      body:
          'Cards are numbered 1 to 12, with 3 copies of each number — 36 total.\n\nA set is 3 cards with the same number.',
      illustration: _IllType.deck,
    ),
    _Slide(
      title: 'On Your Turn',
      body:
          'Each turn, reveal 2 cards from any source:\n\n• Tap Hi or Lo on an opponent\n• Pick a card from the middle pile\n• Reveal your own highest or lowest card',
      illustration: _IllType.turn,
    ),
    _Slide(
      title: 'Match = Bonus Pick!',
      body:
          'If your 2 cards share the same number, you earn a 3rd reveal. Find that third matching card anywhere on the board to collect a set!',
      illustration: _IllType.match,
    ),
    _Slide(
      title: 'No Match? They Flip Back.',
      body:
          'Unmatched cards return face-down. But the AI opponents watch every reveal — they remember card locations and will hunt them down.',
      illustration: _IllType.noMatch,
    ),
    _Slide(
      title: 'First to 3 Sets Wins',
      body:
          'Collect 3 sets of any value to win. Or collect three 7s — the TRIPLE SEVEN — and win the game instantly!',
      illustration: _IllType.win,
    ),
  ];

  void _next() {
    if (_step < _slides.length - 1) {
      setState(() => _step++);
    } else if (widget.reviewOnly) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              GameScreen(playerName: widget.playerName!, tutorialMode: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_step];
    final isLast = _step == _slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: List.generate(_slides.length, (i) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 3,
                      decoration: BoxDecoration(
                        color: i <= _step ? Colors.black : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIllustration(slide.illustration),
                    const SizedBox(height: 36),
                    Text(
                      slide.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      slide.body,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.65,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
              child: AppButton(
                label: isLast ? (widget.reviewOnly ? 'DONE' : 'START PLAYING') : 'NEXT',
                onTap: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(_IllType type) {
    switch (type) {
      case _IllType.logo:
        return const CardBackFan();
      case _IllType.deck:
        return const _DeckIllustration();
      case _IllType.turn:
        return const _TurnIllustration();
      case _IllType.match:
        return const _MatchIllustration();
      case _IllType.noMatch:
        return const _NoMatchIllustration();
      case _IllType.win:
        return const _WinIllustration();
    }
  }
}

// ─────────────────────────────────────────
// DATA
// ─────────────────────────────────────────

enum _IllType { logo, deck, turn, match, noMatch, win }

class _Slide {
  final String title;
  final String body;
  final _IllType illustration;

  const _Slide(
      {required this.title, required this.body, required this.illustration});
}

// ─────────────────────────────────────────
// ILLUSTRATIONS
// ─────────────────────────────────────────

class _DeckIllustration extends StatelessWidget {
  const _DeckIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 60,
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(1, 2)),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '7',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          const Text(
            '× 3 of each number',
            style: TextStyle(fontSize: 12, color: Colors.black54, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class _TurnIllustration extends StatelessWidget {
  const _TurnIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _areaBox('OPPONENTS', Colors.black12),
          _areaBox('MIDDLE PILE', Colors.black12),
          _areaBox('YOUR HAND', Colors.black),
        ],
      ),
    );
  }

  Widget _areaBox(String label, Color color) {
    final isYours = color == Colors.black;
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black26, width: 1),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: isYours ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}

class _MatchIllustration extends StatelessWidget {
  const _MatchIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _matchCard('7', Colors.amber),
          const SizedBox(width: 8),
          _matchCard('7', Colors.amber),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '+',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            width: 60,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black26, width: 2, style: BorderStyle.solid),
            ),
            child: const Center(
              child: Text(
                '?',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black38),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _matchCard(String value, Color bg) {
    return Container(
      width: 60,
      height: 84,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(1, 2)),
        ],
      ),
      child: Center(
        child: Text(
          value,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _NoMatchIllustration extends StatelessWidget {
  const _NoMatchIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _card('5'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '✗',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ),
              _card('9'),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '↩ flip back face-down',
            style: TextStyle(
                fontSize: 12, color: Colors.black54, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _card(String value) {
    return Container(
      width: 60,
      height: 84,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black26, width: 2),
      ),
      child: Center(
        child: Text(
          value,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _WinIllustration extends StatelessWidget {
  const _WinIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 62,
                height: 86,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange, width: 2),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(1, 3)),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '7',
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          const Text(
            'TRIPLE SEVEN',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
