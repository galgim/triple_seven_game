import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../game/game_state.dart';
import '../models.dart';

class GameScreen extends StatefulWidget {
  final String playerName;

  const GameScreen({super.key, this.playerName = 'You'});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameState _gs;

  @override
  void initState() {
    super.initState();
    _gs = GameState(playerName: widget.playerName)..addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _gs.removeListener(_rebuild);
    _gs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isYourTurn = _gs.currentPlayerIndex == 0 && !_gs.gameOver;
    final canReveal = isYourTurn && _gs.picksThisTurn < _gs.maxPicksThisTurn;
    final human = _gs.players[0];
    final ai1 = _gs.players[1];
    final ai2 = _gs.players[2];

    return Scaffold(
      backgroundColor: const Color(0xFFDCF0FB),
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _CrosshatchPainter()),
          ),
          SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 48, 8, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RepaintBoundary(
                        child: _OpponentsRow(
                          ai1: ai1,
                          ai2: ai2,
                          activePlayerIndex: _gs.currentPlayerIndex,
                          canReveal: canReveal,
                          onRevealHighLow: _gs.revealFromPlayer,
                          revealedCards: _gs.revealedCards,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RepaintBoundary(
                              child: _MiddleSection(
                                middleSlots: _gs.middleSlots,
                                canReveal: canReveal,
                                revealedCards: _gs.revealedCards,
                                onReveal: _gs.revealFromMiddle,
                              ),
                            ),
                            _RevealedCardsRow(
                              revealedThisTurn: _gs.revealedThisTurn,
                              bonusTriggered: _gs.bonusTriggered,
                            ),
                          ],
                        ),
                      ),
                      RepaintBoundary(
                        child: _FanHandSection(
                          human: human,
                          isYourTurn: isYourTurn,
                          canReveal: canReveal,
                          revealedCards: _gs.revealedCards,
                          onReveal: _gs.revealOwnCard,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: _SettingsButton(onMenu: () => Navigator.pop(context)),
                ),
                if (_gs.gameOver)
                  _GameOverOverlay(
                    winner: _gs.winner,
                    onPlayAgain: _gs.reset,
                    onMenu: () => Navigator.pop(context),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

// ═══════════════════════════════════════════
// OPPONENTS ROW
// ═══════════════════════════════════════════

class _OpponentsRow extends StatelessWidget {
  final NanaPlayer ai1;
  final NanaPlayer ai2;
  final int activePlayerIndex;
  final bool canReveal;
  final void Function(NanaPlayer, bool) onRevealHighLow;
  final Set<NanaCard> revealedCards;

  const _OpponentsRow({
    required this.ai1,
    required this.ai2,
    required this.activePlayerIndex,
    required this.canReveal,
    required this.onRevealHighLow,
    required this.revealedCards,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AIProfileCard(
            ai: ai1,
            isActive: activePlayerIndex == 1,
            canReveal: canReveal,
            onRevealHighLow: onRevealHighLow,
            revealedCards: revealedCards,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _AIProfileCard(
            ai: ai2,
            isActive: activePlayerIndex == 2,
            canReveal: canReveal,
            onRevealHighLow: onRevealHighLow,
            revealedCards: revealedCards,
          ),
        ),
      ],
    );
  }
}

class _AIProfileCard extends StatelessWidget {
  final NanaPlayer ai;
  final bool isActive;
  final bool canReveal;
  final void Function(NanaPlayer, bool) onRevealHighLow;
  final Set<NanaCard> revealedCards;

  const _AIProfileCard({
    required this.ai,
    required this.isActive,
    required this.canReveal,
    required this.onRevealHighLow,
    required this.revealedCards,
  });

  static const double _fanRadius = 80.0;
  static const double _fanAngle = 65.0 * math.pi / 180.0;
  static const double _fanCardW = 50.0;
  static const double _fanCardH = 70.0;
  static const double _fanLift = 4.0;

  Widget _buildFan(List<NanaCard> hand) {
    final n = hand.length;
    if (n == 0) return const SizedBox.shrink();
    final maxDrop = n > 1 ? _fanRadius * (1 - math.cos(_fanAngle / 2)) : 0.0;
    final fanHeight = _fanCardH + _fanLift + maxDrop;

    return SizedBox(
      height: fanHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cx = constraints.maxWidth / 2;
          return Stack(
            clipBehavior: Clip.none,
            children: List.generate(n, (i) {
              final t = n == 1 ? 0.0 : i / (n - 1) - 0.5;
              final angle = t * _fanAngle;
              final drop = _fanRadius * (1 - math.cos(angle));
              final dx = _fanRadius * math.sin(angle);
              final card = hand[i];
              return Positioned(
                top: _fanLift + drop,
                left: cx + dx - _fanCardW / 2,
                child: Transform.rotate(
                  angle: angle,
                  child: NanaCardWidget(
                    card: card,
                    darkBg: true,
                    tappable: false,
                    highlighted: revealedCards.contains(card),
                    size: _CardSize.mini,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canAct = canReveal && ai.hand.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? Colors.amber : Colors.black26,
          width: isActive ? 2.5 : 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SetDots(player: ai),
          const SizedBox(height: 4),
          Text(
            ai.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          _buildFan(ai.hand),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Lo',
                  bg: Colors.white,
                  fg: Colors.black,
                  onTap: canAct ? () => onRevealHighLow(ai, false) : null,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ActionButton(
                  label: 'Hi',
                  bg: Colors.black,
                  fg: Colors.white,
                  onTap: canAct ? () => onRevealHighLow(ai, true) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// SET DOTS  (●5 ●8 ○)
// ═══════════════════════════════════════════

class _SetDots extends StatelessWidget {
  final NanaPlayer player;

  const _SetDots({required this.player});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        if (i < player.sets.length) {
          final val = player.sets[i][0].value;
          return Text(
            '●$val ',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          );
        } else {
          return const Text(
            '○ ',
            style: TextStyle(
              fontSize: 11,
              color: Colors.black38,
            ),
          );
        }
      }),
    );
  }
}

// ═══════════════════════════════════════════
// MIDDLE SECTION — fixed 3×3 grid
// ═══════════════════════════════════════════

class _MiddleSection extends StatelessWidget {
  final List<NanaCard?> middleSlots;
  final bool canReveal;
  final Set<NanaCard> revealedCards;
  final void Function(NanaCard) onReveal;

  const _MiddleSection({
    required this.middleSlots,
    required this.canReveal,
    required this.revealedCards,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (col) {
              final card = middleSlots[col];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: card == null
                    ? const _EmptySlot()
                    : GestureDetector(
                        onTap: canReveal && !card.faceUp ? () => onReveal(card) : null,
                        child: NanaCardWidget(
                          card: card,
                          darkBg: true,
                          tappable: canReveal && !card.faceUp,
                          highlighted: revealedCards.contains(card),
                          size: _CardSize.pile,
                        ),
                      ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (col) {
              final card = middleSlots[5 + col];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: card == null
                    ? const _EmptySlot()
                    : GestureDetector(
                        onTap: canReveal && !card.faceUp ? () => onReveal(card) : null,
                        child: NanaCardWidget(
                          card: card,
                          darkBg: true,
                          tappable: canReveal && !card.faceUp,
                          highlighted: revealedCards.contains(card),
                          size: _CardSize.pile,
                        ),
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: const Color.fromRGBO(0, 0, 0, 0.15),
          width: 1.5,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// REVEALED CARDS THIS TURN
// ═══════════════════════════════════════════

class _RevealedCardsRow extends StatelessWidget {
  final List<({NanaCard card, NanaPlayer? owner, bool fromMiddle})> revealedThisTurn;
  final bool bonusTriggered;

  const _RevealedCardsRow({
    required this.revealedThisTurn,
    required this.bonusTriggered,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: revealedThisTurn.map((r) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: NanaCardWidget(
              card: r.card,
              darkBg: false,
              tappable: false,
              highlighted: bonusTriggered,
              size: _CardSize.pile,
            ),
          )).toList(),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// FAN HAND SECTION
// ═══════════════════════════════════════════

class _FanHandSection extends StatefulWidget {
  final NanaPlayer human;
  final bool isYourTurn;
  final bool canReveal;
  final Set<NanaCard> revealedCards;
  final void Function(NanaCard) onReveal;

  const _FanHandSection({
    required this.human,
    required this.isYourTurn,
    required this.canReveal,
    required this.revealedCards,
    required this.onReveal,
  });

  @override
  State<_FanHandSection> createState() => _FanHandSectionState();
}

class _FanHandSectionState extends State<_FanHandSection> {
  static const double _radius = 230.0;
  static const double _totalAngle = 50.0 * math.pi / 180.0;
  static const double _cardW = 76.0;
  static const double _cardH = 104.0;
  static const double _liftAmount = 16.0;

  NanaCard? _pressedCard;

  @override
  Widget build(BuildContext context) {
    final human = widget.human;
    final canReveal = widget.canReveal;
    final revealedCards = widget.revealedCards;
    final n = human.hand.length;
    final maxDrop = n > 1 ? _radius * (1 - math.cos(_totalAngle / 2)) : 0.0;
    final fanHeight = _cardH + _liftAmount + maxDrop;

    final unrevealed = human.hand.where((c) => !c.faceUp).toList();
    final lowestCard = unrevealed.isNotEmpty ? unrevealed.first : null;
    final highestCard = unrevealed.length > 1 ? unrevealed.last : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: widget.isYourTurn ? Colors.amber : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  human.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                _SetDots(player: human),
              ],
            ),
          ),
          const SizedBox(height: 6),
          if (n == 0)
            const SizedBox(height: 60)
          else
            SizedBox(
              height: fanHeight,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cx = constraints.maxWidth / 2;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: List.generate(n, (i) {
                      final t = n == 1 ? 0.0 : i / (n - 1) - 0.5;
                      final angle = t * _totalAngle;
                      final drop = _radius * (1 - math.cos(angle));
                      final dx = _radius * math.sin(angle);
                      final card = human.hand[i];
                      final isHighOrLow = card == lowestCard || card == highestCard;
                      final isTappable = canReveal && !card.faceUp && isHighOrLow;
                      final isPressed = _pressedCard == card;
                      final topOffset = _liftAmount + drop - (isPressed ? _liftAmount : 0);
                      final isMuted = !card.faceUp && !isHighOrLow;

                      return Positioned(
                        top: topOffset,
                        left: cx + dx - _cardW / 2,
                        child: Transform.rotate(
                          angle: angle,
                          child: GestureDetector(
                            onTapDown: isTappable
                                ? (_) => setState(() => _pressedCard = card)
                                : null,
                            onTapCancel: isTappable
                                ? () => setState(() => _pressedCard = null)
                                : null,
                            onTap: isTappable
                                ? () {
                                    setState(() => _pressedCard = null);
                                    widget.onReveal(card);
                                  }
                                : null,
                            child: NanaCardWidget(
                              card: card,
                              darkBg: true,
                              tappable: isTappable,
                              highlighted: revealedCards.contains(card),
                              alwaysShowValue: true,
                              muted: isMuted,
                              size: _CardSize.large,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// SETTINGS BUTTON
// ═══════════════════════════════════════════

class _SettingsButton extends StatelessWidget {
  final VoidCallback onMenu;

  const _SettingsButton({required this.onMenu});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'MENU',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: _ActionButton(
                    label: 'BACK TO MENU',
                    bg: Colors.black,
                    fg: Colors.white,
                    onTap: () {
                      Navigator.pop(context);
                      onMenu();
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: _ActionButton(
                    label: 'RESUME',
                    bg: Colors.white,
                    fg: Colors.black,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.settings, color: Colors.white, size: 18),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// GAME OVER OVERLAY
// ═══════════════════════════════════════════

class _GameOverOverlay extends StatelessWidget {
  final String winner;
  final VoidCallback onPlayAgain;
  final VoidCallback onMenu;

  const _GameOverOverlay({
    required this.winner,
    required this.onPlayAgain,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(0, 0, 0, 0.75),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                winner == 'You' ? '🏆' : '😢',
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),
              Text(
                winner == 'You' ? 'YOU WIN!' : '$winner WINS!',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: _ActionButton(
                  label: 'PLAY AGAIN',
                  bg: Colors.black,
                  fg: Colors.white,
                  onTap: onPlayAgain,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: _ActionButton(
                  label: 'MENU',
                  bg: Colors.white,
                  fg: Colors.black,
                  onTap: onMenu,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// CARD WIDGET
// ─────────────────────────────────────────

enum _CardSize { mini, small, medium, pile, large }

class NanaCardWidget extends StatelessWidget {
  final NanaCard card;
  final bool darkBg;
  final bool tappable;
  final bool highlighted;
  final bool alwaysShowValue;
  final bool muted;
  final _CardSize size;

  const NanaCardWidget({
    super.key,
    required this.card,
    required this.darkBg,
    required this.tappable,
    required this.highlighted,
    this.alwaysShowValue = false,
    this.muted = false,
    this.size = _CardSize.small,
  });

  @override
  Widget build(BuildContext context) {
    final showValue = card.faceUp || alwaysShowValue;
    final w = size == _CardSize.large
        ? 76.0
        : size == _CardSize.pile
            ? 64.0
            : size == _CardSize.medium
                ? null
                : size == _CardSize.small
                    ? 34.0
                    : 50.0;
    final h = size == _CardSize.large
        ? 104.0
        : size == _CardSize.pile
            ? 88.0
            : size == _CardSize.medium
                ? 64.0
                : size == _CardSize.small
                    ? 46.0
                    : 70.0;
    final fs = size == _CardSize.large
        ? 22.0
        : size == _CardSize.pile
            ? 20.0
            : size == _CardSize.medium
                ? 18.0
                : size == _CardSize.small
                    ? 12.0
                    : 17.0;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: highlighted
            ? Colors.amber
            : muted
                ? Colors.grey.shade700
                : showValue
                    ? Colors.white
                    : const Color(0xFF003087),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: highlighted
              ? Colors.orange
              : tappable
                  ? Colors.black
                  : Colors.black26,
          width: highlighted ? 2.5 : 1.5,
        ),
        boxShadow: tappable
            ? const [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 2))]
            : null,
      ),
      child: showValue
          ? Stack(
              children: [
                Center(
                  child: Text(
                    '${card.value}',
                    style: TextStyle(
                      fontSize: fs,
                      fontWeight: FontWeight.bold,
                      color: muted ? Colors.white70 : Colors.black,
                    ),
                  ),
                ),
                if (size == _CardSize.large)
                  Positioned(
                    top: 4,
                    left: 5,
                    child: Text(
                      '${card.value}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: muted ? Colors.white70 : Colors.black,
                      ),
                    ),
                  ),
              ],
            )
          : _CardBack(fs: fs),
    );
  }
}

// ─────────────────────────────────────────
// CARD BACK
// ─────────────────────────────────────────

class _CardBack extends StatelessWidget {
  final double fs;

  const _CardBack({required this.fs});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        Center(
          child: Text(
            '777',
            style: TextStyle(
              fontSize: fs * 0.85,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// ACTION BUTTON
// ─────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.bg,
    required this.fg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: onTap != null ? bg : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: onTap != null ? fg : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: onTap != null ? fg : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// BACKGROUND PAINTER
// ─────────────────────────────────────────

class _CrosshatchPainter extends CustomPainter {
  const _CrosshatchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFA8D4F0)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    const spacing = 24.0;

    for (double a = -size.height; a <= size.width; a += spacing) {
      canvas.drawLine(Offset(a, 0), Offset(a + size.height, size.height), paint);
    }

    for (double a = 0; a <= size.width + size.height; a += spacing) {
      canvas.drawLine(Offset(a, 0), Offset(a - size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

