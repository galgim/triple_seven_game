# Triple Seven — Refactor & Optimization Plan

## Current State

| File | Lines | Responsibility |
|------|-------|----------------|
| `lib/main.dart` | 198 | App entry, main menu, how-to-play screen |
| `lib/models.dart` | 98 | Card, Player, Deck, GameLogic |
| `lib/game_screen.dart` | 800 | Game state, AI logic, ALL UI widgets |

**The core problem:** `game_screen.dart` is doing three different jobs at once — managing game state, running AI turns, and rendering every piece of UI. This makes it hard to read, test, or change any one part without touching the others.

---

## Problem Areas

### 1. No separation between game logic and UI
`_GameScreenState` holds both the game rules (who picks what, when sets form, win condition) and the Flutter widget tree. If you wanted to add a different UI theme or write a test for the AI, you can't — they're glued together.

### 2. AI logic lives inside the widget
`_aiReveal()` is a method on the screen's state class. It uses `setState` and `Future.delayed` directly, which ties AI decision-making to the render cycle. Extracting or testing it in isolation isn't possible right now.

### 3. `_GameScreenState` is 370 lines of mixed concerns
State fields, turn management, set collection, AI behavior, and UI helpers are all in one class. Finding any one piece requires scanning the whole thing.

### 4. Private widget classes at the bottom of `game_screen.dart`
`_AISection`, `_MiddleSection`, `_HumanSection`, `_SetsAndLogRow`, `_GameOverWidget`, `NanaCardWidget`, `_ActionButton` — 7 widget classes appended to the same file. They're reusable but not accessible from anywhere else, and they make the file hard to navigate.

### 5. Turn sequencing via nested `Future.delayed`
The flow for a turn (reveal → check match → bonus reveal → collect set → next turn) is expressed as chained `Future.delayed` callbacks inside `_afterReveal`. Hard to follow, and timing bugs are easy to introduce.

---

## Decisions — LOCKED

| # | Decision | Choice |
|---|----------|--------|
| A | State management | **ChangeNotifier** — no new packages, Flutter-native, clean separation |
| B | Turn timing | **Move delays into `GameState`** — UI just reacts to notified state changes |
| C | Widget file splitting | **Group by screen** — game widgets stay in `game_screen.dart`, menu widgets in `menu_screen.dart` |

---

## Target File Structure

```
lib/
  main.dart                   # App entry + MaterialApp routing only
  screens/
    menu_screen.dart          # MainMenuScreen + HowToPlayScreen + their private widgets
    game_screen.dart          # GameScreen widget + all game UI widgets (_AISection, etc.)
  game/
    game_state.dart           # GameState extends ChangeNotifier — all state, rules, AI, timing
  models.dart                 # Unchanged: NanaCard, NanaPlayer, NanaDeck, NanaGameLogic
```

No new packages. No changes to `models.dart`.

---

## What Changes in Each File

### `main.dart` (198 → ~30 lines)
- Keep only `main()` and `TripleSevenApp`
- Route `/` to `MenuScreen`, `/game` to `GameScreen`
- Remove `MainMenuScreen`, `HowToPlayScreen`, `_RuleSection` — those move to `menu_screen.dart`

### `screens/menu_screen.dart` (new, ~170 lines)
- `MainMenuScreen`, `HowToPlayScreen`, `_RuleSection`, `_menuButton` helper
- No game logic, no imports from `game/`

### `screens/game_screen.dart` (~800 → ~500 lines)
- `GameScreen` becomes a thin `StatefulWidget` that:
  - Creates a `GameState` in `initState`, adds a listener that calls `setState(() {})`
  - Disposes the `GameState` in `dispose`
  - Reads from `GameState` in `build` — no game logic here
- All the UI widget classes stay in this file (`_AISection`, `_MiddleSection`, etc.) — they receive plain data as constructor args, no direct state access
- No `Future.delayed`, no AI calls, no `_setupGame` — those all move to `GameState`

### `game/game_state.dart` (new, ~250 lines)
- `class GameState extends ChangeNotifier`
- Owns all fields currently on `_GameScreenState`: `players`, `middlePile`, `currentPlayerIndex`, `gameLog`, `gameOver`, `winner`, turn counters
- Owns all methods: `setup()`, `revealFromPlayer()`, `revealFromMiddle()`, `revealOwnCard()`, `_afterReveal()`, `_collectSet()`, `_nextTurn()`, `_aiReveal()`
- Calls `notifyListeners()` wherever `setState()` was called before
- `Future.delayed` calls stay here — they call `notifyListeners()` instead of `setState()`
- No Flutter widget imports (only `dart:async`, `dart:math`, and `models.dart`)

---

## How the ChangeNotifier Wiring Works

```dart
// game_screen.dart
class _GameScreenState extends State<GameScreen> {
  late final GameState _gs;

  @override
  void initState() {
    super.initState();
    _gs = GameState()..addListener(_rebuild);
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
    // reads from _gs.players, _gs.gameLog, etc.
    // calls _gs.revealFromPlayer(), _gs.revealFromMiddle(), etc.
  }
}
```

No Provider package needed — `addListener` + `setState` is sufficient for a single screen.

---

## Implementation Order

1. Create `game/game_state.dart` — extract all logic from `_GameScreenState`, verify it compiles
2. Update `screens/game_screen.dart` — wire `GameState`, strip logic, confirm game still plays correctly
3. Create `screens/menu_screen.dart` — move menu/how-to-play code out of `main.dart`
4. Slim down `main.dart` to routing only

Each step leaves the app in a working state before moving to the next.

---

## What This Is NOT
- Not changing any game rules or mechanics
- Not adding features
- Not changing the visual design
- Not adding external packages

---

## Out of Scope (deferred)
- Tests
- AI difficulty settings
- Further splitting of widget classes into their own files
