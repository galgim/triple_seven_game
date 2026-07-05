import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models.dart';

class GameState extends ChangeNotifier {
  late List<NanaPlayer> players;
  late List<NanaCard> middlePile;
  late List<NanaCard?> middleSlots;
  int currentPlayerIndex = 0;
  String gameLog = '';
  bool gameOver = false;
  String winner = '';

  int picksThisTurn = 0;
  int maxPicksThisTurn = 2;
  bool bonusTriggered = false;
  List<({NanaCard card, NanaPlayer? owner, bool fromMiddle})> revealedThisTurn = [];
  Set<NanaCard> revealedCards = {};

  final Random _random = Random();
  bool _disposed = false;
  final String playerName;

  GameState({this.playerName = 'You'}) {
    _init();
  }

  void _init() {
    final deck = NanaDeck();
    players = [
      NanaPlayer(name: playerName, isHuman: true),
      NanaPlayer(name: 'AI 1', isHuman: false),
      NanaPlayer(name: 'AI 2', isHuman: false),
    ];
    for (int i = 0; i < 9; i++) {
      for (var player in players) {
        player.hand.add(deck.draw());
      }
    }
    for (var player in players) {
      player.hand.sort((a, b) => a.value.compareTo(b.value));
    }
    middlePile = deck.cards.toList();
    middlePile.sort((a, b) => a.value.compareTo(b.value));
    middleSlots = List<NanaCard?>.from(middlePile);
    gameLog = 'Your turn — reveal 2 cards.';
    currentPlayerIndex = 0;
    gameOver = false;
    winner = '';
    _resetTurnCounters();
  }

  void reset() {
    _init();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // ── Internal helpers ──

  void _sortAllHands() {
    for (var p in players) p.hand.sort((a, b) => a.value.compareTo(b.value));
  }

  void _resetTurnCounters() {
    picksThisTurn = 0;
    maxPicksThisTurn = 2;
    bonusTriggered = false;
    revealedThisTurn = [];
    revealedCards = {};
  }

  void _flipRevealedBack() {
    for (final r in revealedThisTurn) r.card.faceUp = false;
    revealedThisTurn = [];
    revealedCards = {};
  }

  void _addRevealed(NanaCard card, NanaPlayer? owner, bool fromMiddle) {
    revealedThisTurn.add((card: card, owner: owner, fromMiddle: fromMiddle));
    revealedCards = {for (final r in revealedThisTurn) r.card};
  }

  void _log(String msg) {
    if (_disposed) return;
    gameLog = msg;
    notifyListeners();
  }

  // ── Turn flow ──

  void _afterReveal(NanaPlayer currentPlayer) {
    picksThisTurn++;
    final values = revealedThisTurn.map((r) => r.card.value).toList();
    final latest = revealedThisTurn.last;
    final source = latest.fromMiddle
        ? 'the middle pile'
        : latest.owner == currentPlayer
            ? '${currentPlayer.isHuman ? "your" : "their"} hand'
            : latest.owner?.name ?? '?';

    if (picksThisTurn == 1) {
      _log('${currentPlayer.name} revealed ${values[0]} from $source.');
    } else if (picksThisTurn == 2) {
      if (values[0] == values[1]) {
        bonusTriggered = true;
        maxPicksThisTurn = 3;
        _log('🔥 MATCH! Both ${values[0]} — find the 3rd!');
      } else {
        _log('No match (${values[0]} & ${values[1]}). Flipping back...');
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (_disposed) return;
          _flipRevealedBack();
          notifyListeners();
          Future.delayed(const Duration(milliseconds: 600), _nextTurn);
        });
      }
    } else if (picksThisTurn == 3) {
      if (values[0] == values[1] && values[1] == values[2]) {
        final fromOwnHand = !latest.fromMiddle && latest.owner == currentPlayer;
        final extra = (fromOwnHand && !currentPlayer.isHuman) ? ' Found it in their own hand!' : '';
        _log('🎉 TRIPLE ${values[0]}! Collecting set!$extra');
        Future.delayed(const Duration(milliseconds: 800), () {
          if (_disposed) return;
          _collectSet(currentPlayer);
          notifyListeners();
          Future.delayed(const Duration(milliseconds: 600), _nextTurn);
        });
      } else {
        _log('No triple (${values[0]}, ${values[1]}, ${values[2]}). Flipping back...');
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (_disposed) return;
          _flipRevealedBack();
          notifyListeners();
          Future.delayed(const Duration(milliseconds: 600), _nextTurn);
        });
      }
    }

    if (!gameOver &&
        !currentPlayer.isHuman &&
        picksThisTurn < maxPicksThisTurn &&
        !(picksThisTurn == 2 && values.length >= 2 && values[0] != values[1])) {
      Future.delayed(const Duration(milliseconds: 1400), _aiReveal);
    }
  }

  void _collectSet(NanaPlayer collector) {
    final setCards = revealedThisTurn.map((r) => r.card).toList();
    for (final r in revealedThisTurn) {
      if (r.fromMiddle) {
        middlePile.remove(r.card);
        final idx = middleSlots.indexOf(r.card);
        if (idx != -1) middleSlots[idx] = null;
      } else {
        r.owner?.hand.remove(r.card);
      }
    }
    collector.sets.add(setCards);
    revealedThisTurn = [];
    revealedCards = {};
    _sortAllHands();
    if (setCards[0].value == 7) {
      gameOver = true;
      winner = collector.name;
      gameLog = '🎰 ${collector.name} wins with Triple Seven!';
      return;
    }
    _log('${collector.name} collected ${setCards[0].value}s! (${collector.setCount}/3)');
    if (NanaGameLogic.hasWon(collector)) {
      gameOver = true;
      winner = collector.name;
      gameLog = '${collector.name} wins with 3 sets! 🏆';
    }
  }

  void _nextTurn() {
    if (gameOver || _disposed) return;
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    _resetTurnCounters();
    notifyListeners();
    if (!players[currentPlayerIndex].isHuman) {
      _log('${players[currentPlayerIndex].name} is thinking...');
      Future.delayed(const Duration(milliseconds: 1500), _aiReveal);
    } else {
      _log('Your turn — reveal 2 cards.');
    }
  }

  // ── AI ──

  void _aiReveal() {
    if (gameOver || _disposed) return;
    final ai = players[currentPlayerIndex];
    final others = players.where((p) => p != ai && p.hand.isNotEmpty).toList();

    // Bonus turn: try to find the matching 3rd card
    if (bonusTriggered && picksThisTurn == 2 && revealedThisTurn.isNotEmpty) {
      final targetValue = revealedThisTurn[0].card.value;
      for (final target in others) {
        final unrevealed = target.hand.where((c) => !c.faceUp).toList();
        if (unrevealed.isEmpty) continue;
        NanaCard? matchCard;
        if (unrevealed.last.value == targetValue) matchCard = unrevealed.last;
        else if (unrevealed.first.value == targetValue) matchCard = unrevealed.first;
        if (matchCard != null) {
          matchCard.faceUp = true;
          _addRevealed(matchCard, target, false);
          notifyListeners();
          _afterReveal(ai);
          return;
        }
      }
      final middleMatch = middlePile.where((c) => c.value == targetValue && !c.faceUp).toList();
      if (middleMatch.isNotEmpty) {
        final card = middleMatch.first;
        card.faceUp = true;
        _addRevealed(card, null, true);
        notifyListeners();
        _afterReveal(ai);
        return;
      }
      final ownMatch = ai.hand.where((c) => c.value == targetValue).toList();
      if (ownMatch.isNotEmpty) {
        final card = ownMatch.first;
        card.faceUp = true;
        _addRevealed(card, ai, false);
        notifyListeners();
        _afterReveal(ai);
        return;
      }
    }

    // Normal turn: random choice between middle and opponent high/low
    final choice = _random.nextInt(3);
    if (choice == 0 && middlePile.isNotEmpty) {
      final available = middlePile.where((c) => !c.faceUp).toList();
      if (available.isNotEmpty) {
        final card = available[_random.nextInt(available.length)];
        card.faceUp = true;
        _addRevealed(card, null, true);
        notifyListeners();
        _afterReveal(ai);
        return;
      }
    }
    if (others.isNotEmpty) {
      final target = others[_random.nextInt(others.length)];
      final unrevealed = target.hand.where((c) => !c.faceUp).toList();
      if (unrevealed.isNotEmpty) {
        final card = _random.nextBool() ? unrevealed.last : unrevealed.first;
        card.faceUp = true;
        _addRevealed(card, target, false);
        notifyListeners();
        _afterReveal(ai);
        return;
      }
    }
    if (middlePile.isNotEmpty) {
      final available = middlePile.where((c) => !c.faceUp).toList();
      if (available.isNotEmpty) {
        final card = available[_random.nextInt(available.length)];
        card.faceUp = true;
        _addRevealed(card, null, true);
        notifyListeners();
        _afterReveal(ai);
        return;
      }
    }
    _nextTurn();
  }

  // ── Public API (called by UI) ──

  void revealFromPlayer(NanaPlayer target, bool highest) {
    if (gameOver || currentPlayerIndex != 0) return;
    if (picksThisTurn >= maxPicksThisTurn) return;
    if (target.hand.isEmpty) return;
    final available = target.hand.where((c) => !revealedCards.contains(c)).toList();
    if (available.isEmpty) {
      _log('No more unrevealed cards from ${target.name}!');
      return;
    }
    final card = highest ? available.last : available.first;
    card.faceUp = true;
    _addRevealed(card, target, false);
    notifyListeners();
    _afterReveal(players[0]);
  }

  void revealFromMiddle(NanaCard card) {
    if (gameOver || currentPlayerIndex != 0) return;
    if (picksThisTurn >= maxPicksThisTurn) return;
    if (card.faceUp) return;
    card.faceUp = true;
    _addRevealed(card, null, true);
    notifyListeners();
    _afterReveal(players[0]);
  }

  void revealOwnCard(NanaCard card) {
    if (gameOver || currentPlayerIndex != 0) return;
    if (picksThisTurn >= maxPicksThisTurn) return;
    if (card.faceUp) return;
    card.faceUp = true;
    _addRevealed(card, players[0], false);
    notifyListeners();
    _afterReveal(players[0]);
  }
}
