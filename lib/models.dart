import 'dart:math';

// ─────────────────────────────────────────
// CARD MODEL
// ─────────────────────────────────────────
class NanaCard {
  final int id;   // unique 0-35, used for save/load serialisation
  final int value;
  bool faceUp;

  NanaCard({required this.id, required this.value, this.faceUp = false});
}

// ─────────────────────────────────────────
// PLAYER MODEL
// ─────────────────────────────────────────
class NanaPlayer {
  final String name;
  final bool isHuman;
  List<NanaCard> hand;
  List<List<NanaCard>> sets;

  NanaPlayer({
    required this.name,
    required this.isHuman,
  })  : hand = [],
        sets = [];

  int get setCount => sets.length;
  int get handCount => hand.length;

  NanaCard? get highestCard => hand.isEmpty ? null : hand.last;
  NanaCard? get lowestCard  => hand.isEmpty ? null : hand.first;
}

// ─────────────────────────────────────────
// DECK
// ─────────────────────────────────────────
class NanaDeck {
  final List<NanaCard> cards = [];
  final Random _random = Random();

  NanaDeck() {
    _build();
  }

  void _build() {
    cards.clear();
    int nextId = 0;
    for (int v = 1; v <= 12; v++) {
      for (int c = 0; c < 3; c++) {
        cards.add(NanaCard(id: nextId++, value: v));
      }
    }
    cards.shuffle(_random);
  }

  NanaCard draw() => cards.removeLast();
  bool get isEmpty => cards.isEmpty;
  int get remaining => cards.length;
}

// ─────────────────────────────────────────
// AI MEMORY BANK
// ─────────────────────────────────────────
class CardSighting {
  final NanaCard card;
  final int? ownerIndex; // null = middle pile
  bool collected = false;

  CardSighting({required this.card, this.ownerIndex});
}

class AiMemory {
  final List<CardSighting> _sightings = [];
  final Set<NanaCard> _seenCards = {};

  void observe(NanaCard card, int? ownerIndex) {
    if (!_seenCards.add(card)) return;
    _sightings.add(CardSighting(card: card, ownerIndex: ownerIndex));
  }

  void markCollected(List<NanaCard> cards) {
    final cardSet = cards.toSet();
    for (final s in _sightings) {
      if (cardSet.contains(s.card)) s.collected = true;
    }
  }

  void clear() {
    _sightings.clear();
    _seenCards.clear();
  }

  List<CardSighting> knownLocationsOf(int value) {
    return _sightings
        .where((s) => s.card.value == value && !s.collected && !s.card.faceUp)
        .toList();
  }
}

// ─────────────────────────────────────────
// GAME LOGIC HELPER
// ─────────────────────────────────────────
class NanaGameLogic {
  static bool checkAndRemoveSets(NanaPlayer player) {
    Map<int, List<NanaCard>> groups = {};
    for (var card in player.hand) {
      groups.putIfAbsent(card.value, () => []).add(card);
    }
    bool found = false;
    for (var entry in groups.entries) {
      if (entry.value.length >= 3) {
        final set = entry.value.take(3).toList();
        for (var c in set) {
          player.hand.remove(c);
        }
        player.sets.add(set);
        found = true;
      }
    }
    return found;
  }

  static bool hasWon(NanaPlayer player) => player.sets.length >= 3;
}
