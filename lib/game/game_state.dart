import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  late List<AiMemory> _aiMemories;
  final Random _random = Random();
  bool _disposed = false;
  final String playerName;

  bool _paused = false;
  void Function()? _pendingAction;

  // ── Constructors ──

  GameState({this.playerName = 'You'}) {
    _init();
  }

  GameState._restore({
    required this.playerName,
    required List<NanaPlayer> restoredPlayers,
    required List<NanaCard> restoredMiddlePile,
    required List<NanaCard?> restoredMiddleSlots,
    required int restoredPlayerIndex,
    required int restoredPicks,
    required int restoredMaxPicks,
    required bool restoredBonus,
    required String restoredLog,
    required List<({NanaCard card, NanaPlayer? owner, bool fromMiddle})> restoredRevealed,
  }) {
    players = restoredPlayers;
    middlePile = restoredMiddlePile;
    middleSlots = restoredMiddleSlots;
    currentPlayerIndex = restoredPlayerIndex;
    picksThisTurn = restoredPicks;
    maxPicksThisTurn = restoredMaxPicks;
    bonusTriggered = restoredBonus;
    gameLog = restoredLog;
    revealedThisTurn = restoredRevealed;
    revealedCards = {for (final r in revealedThisTurn) r.card};
    _aiMemories = [AiMemory(), AiMemory()];

    // For AI turns: undo any mid-turn progress and start fresh
    if (!players[currentPlayerIndex].isHuman) {
      if (revealedThisTurn.isNotEmpty) {
        _flipRevealedBack();
        _resetTurnCounters();
      }
      _delayed(const Duration(milliseconds: 900), _aiReveal);
    }
  }

  // ── Save / Load ──

  static const _saveKey = 'saved_game';

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_saveKey, jsonEncode(toJson()));
  }

  static Future<void> clearSave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saveKey);
  }

  static Future<Map<String, dynamic>?> loadSave() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_saveKey);
    if (str == null) return null;
    return jsonDecode(str) as Map<String, dynamic>;
  }

  Map<String, dynamic> toJson() {
    final allCards = <NanaCard>{};
    for (final p in players) {
      allCards.addAll(p.hand);
      for (final s in p.sets) { allCards.addAll(s); }
    }
    for (final c in middleSlots) { if (c != null) allCards.add(c); }
    for (final r in revealedThisTurn) { allCards.add(r.card); }

    return {
      'playerName': playerName,
      'currentPlayerIndex': currentPlayerIndex,
      'picksThisTurn': picksThisTurn,
      'maxPicksThisTurn': maxPicksThisTurn,
      'bonusTriggered': bonusTriggered,
      'gameLog': gameLog,
      'cards': {
        for (final c in allCards)
          '${c.id}': {'value': c.value, 'faceUp': c.faceUp}
      },
      'players': [
        for (final p in players)
          {
            'name': p.name,
            'isHuman': p.isHuman,
            'hand': p.hand.map((c) => c.id).toList(),
            'sets': p.sets.map((s) => s.map((c) => c.id).toList()).toList(),
          }
      ],
      'middleSlots': middleSlots.map((c) => c?.id).toList(),
      'revealedThisTurn': revealedThisTurn.map((r) => {
        'cardId': r.card.id,
        'ownerIndex': r.owner != null ? players.indexOf(r.owner!) : null,
        'fromMiddle': r.fromMiddle,
      }).toList(),
    };
  }

  static GameState fromJson(Map<String, dynamic> json) {
    final cardsData = json['cards'] as Map<String, dynamic>;
    final cardMap = <int, NanaCard>{};
    cardsData.forEach((key, value) {
      final id = int.parse(key);
      final data = value as Map<String, dynamic>;
      // ignore: deprecated_member_use
      cardMap[id] = NanaCard(id: id, value: data['value'] as int, faceUp: data['faceUp'] as bool);
    });

    final playersData = json['players'] as List<dynamic>;
    final players = <NanaPlayer>[];
    for (final pd in playersData) {
      final p = NanaPlayer(name: pd['name'] as String, isHuman: pd['isHuman'] as bool);
      p.hand = (pd['hand'] as List<dynamic>).map((id) => cardMap[id as int]!).toList();
      p.sets = (pd['sets'] as List<dynamic>)
          .map((s) => (s as List<dynamic>).map((id) => cardMap[id as int]!).toList())
          .toList();
      players.add(p);
    }

    final middleSlots = (json['middleSlots'] as List<dynamic>)
        .map((id) => id == null ? null : cardMap[id as int])
        .toList();
    final middlePile = middleSlots.whereType<NanaCard>().toList();

    final revealedData = json['revealedThisTurn'] as List<dynamic>;
    final revealedThisTurn = revealedData.map((r) {
      final ownerIdx = r['ownerIndex'] as int?;
      return (
        card: cardMap[r['cardId'] as int]!,
        owner: ownerIdx != null ? players[ownerIdx] : null,
        fromMiddle: r['fromMiddle'] as bool,
      );
    }).toList();

    return GameState._restore(
      playerName: json['playerName'] as String,
      restoredPlayers: players,
      restoredMiddlePile: middlePile,
      restoredMiddleSlots: middleSlots,
      restoredPlayerIndex: json['currentPlayerIndex'] as int,
      restoredPicks: json['picksThisTurn'] as int,
      restoredMaxPicks: json['maxPicksThisTurn'] as int,
      restoredBonus: json['bonusTriggered'] as bool,
      restoredLog: json['gameLog'] as String,
      restoredRevealed: revealedThisTurn,
    );
  }

  // ── Pause / Resume ──

  void pause() => _paused = true;

  void resume() {
    if (!_paused) return;
    _paused = false;
    final action = _pendingAction;
    _pendingAction = null;
    if (action != null) action();
  }

  // Wraps Future.delayed so it respects the paused state.
  void _delayed(Duration d, void Function() action) {
    Future.delayed(d, () {
      if (_disposed) return;
      if (_paused) {
        _pendingAction = action;
        return;
      }
      action();
    });
  }

  // ── Init ──

  void _init() {
    final deck = NanaDeck();
    players = [
      NanaPlayer(name: playerName, isHuman: true),
      NanaPlayer(name: 'Andrew', isHuman: false),
      NanaPlayer(name: 'Joey', isHuman: false),
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
    _aiMemories = [AiMemory(), AiMemory()];
    _resetTurnCounters();
  }

  void reset() {
    _pendingAction = null;
    _paused = false;
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
    for (var p in players) { p.hand.sort((a, b) => a.value.compareTo(b.value)); }
  }

  void _resetTurnCounters() {
    picksThisTurn = 0;
    maxPicksThisTurn = 2;
    bonusTriggered = false;
    revealedThisTurn = [];
    revealedCards = {};
  }

  void _flipRevealedBack() {
    for (final r in revealedThisTurn) { r.card.faceUp = false; }
    revealedThisTurn = [];
    revealedCards = {};
  }

  void _addRevealed(NanaCard card, NanaPlayer? owner, bool fromMiddle) {
    revealedThisTurn.add((card: card, owner: owner, fromMiddle: fromMiddle));
    revealedCards = {for (final r in revealedThisTurn) r.card};
    final ownerIndex = owner != null ? players.indexOf(owner) : null;
    for (int i = 1; i < players.length; i++) {
      _aiMemories[i - 1].observe(card, ownerIndex);
    }
  }

  void _log(String msg) {
    if (_disposed) return;
    gameLog = msg;
  }

  static NanaCard? _firstWhere(List<NanaCard> list, bool Function(NanaCard) test) {
    for (final c in list) { if (test(c)) return c; }
    return null;
  }

  static NanaCard? _lastWhere(List<NanaCard> list, bool Function(NanaCard) test) {
    for (int i = list.length - 1; i >= 0; i--) { if (test(list[i])) return list[i]; }
    return null;
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
        notifyListeners();
      } else {
        _log('No match (${values[0]} & ${values[1]}). Flipping back...');
        notifyListeners();
        _delayed(const Duration(milliseconds: 600), () {
          if (_disposed) return;
          _flipRevealedBack();
          notifyListeners();
          _delayed(const Duration(milliseconds: 350), _nextTurn);
        });
      }
    } else if (picksThisTurn == 3) {
      if (values[0] == values[1] && values[1] == values[2]) {
        final fromOwnHand = !latest.fromMiddle && latest.owner == currentPlayer;
        final extra = (fromOwnHand && !currentPlayer.isHuman) ? ' Found it in their own hand!' : '';
        _log('🎉 TRIPLE ${values[0]}! Collecting set!$extra');
        _delayed(const Duration(milliseconds: 450), () {
          if (_disposed) return;
          _collectSet(currentPlayer);
          notifyListeners();
          _delayed(const Duration(milliseconds: 350), _nextTurn);
        });
      } else {
        _log('No triple (${values[0]}, ${values[1]}, ${values[2]}). Flipping back...');
        notifyListeners();
        _delayed(const Duration(milliseconds: 600), () {
          if (_disposed) return;
          _flipRevealedBack();
          notifyListeners();
          _delayed(const Duration(milliseconds: 350), _nextTurn);
        });
      }
    }

    if (!gameOver &&
        !currentPlayer.isHuman &&
        picksThisTurn < maxPicksThisTurn &&
        !(picksThisTurn == 2 && values.length >= 2 && values[0] != values[1])) {
      _delayed(const Duration(milliseconds: 1400), _aiReveal);
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
    for (final mem in _aiMemories) {
      mem.markCollected(setCards);
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
      _delayed(const Duration(milliseconds: 1200), _aiReveal);
    } else {
      _log('Your turn — reveal 2 cards.');
    }
  }

  // ── AI ──

  AiMemory _memoryFor(int playerIndex) => _aiMemories[playerIndex - 1];

  bool _tryRevealFromSighting(CardSighting sighting, NanaPlayer ai) {
    final card = sighting.card;
    if (card.faceUp) return false;
    if (sighting.ownerIndex == null) {
      if (!middlePile.contains(card)) return false;
      card.faceUp = true;
      _addRevealed(card, null, true);
      notifyListeners();
      _afterReveal(ai);
      return true;
    } else {
      final owner = players[sighting.ownerIndex!];
      if (!owner.hand.contains(card)) return false;
      card.faceUp = true;
      _addRevealed(card, owner, false);
      notifyListeners();
      _afterReveal(ai);
      return true;
    }
  }

  void _aiReveal() {
    if (gameOver || _disposed) return;
    final ai = players[currentPlayerIndex];
    final memory = _memoryFor(currentPlayerIndex);
    final others = players.where((p) => p != ai && p.hand.isNotEmpty).toList();

    if (bonusTriggered && picksThisTurn == 2 && revealedThisTurn.isNotEmpty) {
      final targetValue = revealedThisTurn[0].card.value;

      for (final sighting in memory.knownLocationsOf(targetValue)) {
        if (_tryRevealFromSighting(sighting, ai)) return;
      }

      for (final target in others) {
        final hi = _lastWhere(target.hand, (c) => !c.faceUp);
        if (hi == null) continue;
        final lo = _firstWhere(target.hand, (c) => !c.faceUp)!;
        final matchCard = hi.value == targetValue
            ? hi
            : (lo.value == targetValue ? lo : null);
        if (matchCard != null) {
          matchCard.faceUp = true;
          _addRevealed(matchCard, target, false);
          notifyListeners();
          _afterReveal(ai);
          return;
        }
      }
      final middleMatch = _firstWhere(middlePile, (c) => c.value == targetValue && !c.faceUp);
      if (middleMatch != null) {
        middleMatch.faceUp = true;
        _addRevealed(middleMatch, null, true);
        notifyListeners();
        _afterReveal(ai);
        return;
      }
      final ownMatch = _firstWhere(ai.hand, (c) => c.value == targetValue && !c.faceUp);
      if (ownMatch != null) {
        ownMatch.faceUp = true;
        _addRevealed(ownMatch, ai, false);
        notifyListeners();
        _afterReveal(ai);
        return;
      }
    }

    if (picksThisTurn == 0) {
      final valueCounts = <int, int>{};
      for (final c in ai.hand) {
        valueCounts[c.value] = (valueCounts[c.value] ?? 0) + 1;
      }
      for (final entry in valueCounts.entries.where((e) => e.value >= 2)) {
        for (final sighting in memory.knownLocationsOf(entry.key)) {
          if (_tryRevealFromSighting(sighting, ai)) return;
        }
      }
      for (final entry in valueCounts.entries.where((e) => e.value == 1)) {
        for (final sighting in memory.knownLocationsOf(entry.key)) {
          if (_tryRevealFromSighting(sighting, ai)) return;
        }
      }
    }

    if (picksThisTurn == 1 && revealedThisTurn.isNotEmpty) {
      final targetValue = revealedThisTurn[0].card.value;
      for (final sighting in memory.knownLocationsOf(targetValue)) {
        if (_tryRevealFromSighting(sighting, ai)) return;
      }
    }

    // Fallback: random
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
      final lo = _firstWhere(target.hand, (c) => !c.faceUp);
      if (lo != null) {
        final hi = _lastWhere(target.hand, (c) => !c.faceUp)!;
        final card = _random.nextBool() ? hi : lo;
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

  // ── Public API ──

  void revealFromPlayer(NanaPlayer target, bool highest) {
    if (gameOver || currentPlayerIndex != 0) return;
    if (picksThisTurn >= maxPicksThisTurn) return;
    if (target.hand.isEmpty) return;
    final card = highest
        ? _lastWhere(target.hand, (c) => !revealedCards.contains(c))
        : _firstWhere(target.hand, (c) => !revealedCards.contains(c));
    if (card == null) {
      _log('No more unrevealed cards from ${target.name}!');
      return;
    }
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
