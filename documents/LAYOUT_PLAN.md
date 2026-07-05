# Triple Seven — Layout Plan

## Current Screen Inventory

### Main Menu (`menu_screen.dart`)
- Title block: "TRIPLE / SEVEN" (large, centered)
- Subtitle: "A card game for 3 players"
- PLAY button (black, filled)
- HOW TO PLAY button (white, outlined)

### How To Play (`menu_screen.dart`)
- AppBar with back button
- Scrollable list of rule sections (title + body + divider)

### Game Screen (`screens/game_screen.dart`)
- AppBar: "TRIPLE SEVEN"
- Turn banner (full-width, color changes by state)
- AI 1 row (cards + High/Low buttons)
- AI 2 row (cards + High/Low buttons)
- Middle pile (3-column card grid)
- `Spacer` (pushes bottom content down)
- Sets + Log row (sets panel left, game log right)
- Your hand (large cards, anchored to bottom)
- Game over bar (appears below hand when game ends)

---

## Current Game Screen Layout (ASCII)

```
┌──────────────────────────────────┐
│         TRIPLE SEVEN  (AppBar)   │
├──────────────────────────────────┤
│  [Turn banner — full width]      │
├──────────────────────────────────┤
│  AI 1   [High] [Low]   9 cards   │
│  □ □ □ □ □ □ □ □ □               │
├──────────────────────────────────┤
│  AI 2   [High] [Low]   9 cards   │
│  □ □ □ □ □ □ □ □ □               │
├──────────────────────────────────┤
│  MIDDLE PILE  •  9 cards         │
│  [ □ ]  [ □ ]  [ □ ]            │
│  [ □ ]  [ □ ]  [ □ ]            │
│  [ □ ]  [ □ ]  [ □ ]            │
├──────────────────────────────────┤
│           (spacer)               │
├──────────────────────────────────┤
│  SETS         │  Game log text   │
│  You  0/3     │                  │
│  AI 1 0/3     │                  │
│  AI 2 0/3     │                  │
├──────────────────────────────────┤
│  YOUR HAND  ← YOUR TURN          │
│  [1][2][3][4][5][6][7][8][9]    │
└──────────────────────────────────┘
```

---

## Areas to Discuss

### 1. Game Screen — Overall Layout ✅ DECIDED

**Decision: Opponents strip (Option A)**
Replace the two separate AI card rows with a single compact strip. No individual card boxes — just name, set progress, card count, and High/Low buttons per AI. Cuts the screen from 7 distinct zones down to 4.

**Target layout:**
```
┌──────────────────────────────────┐
│         TRIPLE SEVEN  (AppBar)   │
├──────────────────────────────────┤
│  [Turn banner — full width]      │
├──────────────────────────────────┤
│  AI 1  ●○○  9 cards  [Hi] [Lo]  │
│  AI 2  ●○○  9 cards  [Hi] [Lo]  │  ← opponents strip (one container)
├──────────────────────────────────┤
│  MIDDLE PILE  •  9 cards         │
│  [ □ ]  [ □ ]  [ □ ]            │
│  [ □ ]  [ □ ]  [ □ ]            │
│  [ □ ]  [ □ ]  [ □ ]            │
├──────────────────────────────────┤
│           (spacer)               │
├──────────────────────────────────┤
│  SETS/LOG                        │
├──────────────────────────────────┤
│  YOUR HAND                       │
│  [1][2][3][4][5][6][7][8][9]    │
└──────────────────────────────────┘
```

**What the opponents strip shows per AI:**
- Name (AI 1 / AI 2)
- Set progress as dots: ●●○ = 2/3 sets (simpler than number chips)
- Card count
- High / Low buttons — only shown when it's the human's turn and the AI has cards

**What's removed:**
- The 9 individual face-down card boxes per AI (they showed `?` — no real information)
- The separate container/border per AI (both AIs share one strip container)

**Open sub-questions for the strip:**
- Should both AI rows always be visible, or only the one you're currently able to pick from?
- Should the active AI (whose turn it is) be highlighted differently inside the strip?
- Should the set dots show the actual number collected (e.g. ●5) or just filled/empty dots?

---

### 2. Turn Banner
Current: full-width colored bar that changes text and color based on turn state.

Questions:
- Is the color-change (black → orange for bonus) clear enough?
- Should it also animate or pulse on bonus turns?
- Should it be removed in favor of inline indicators on each section?

---

### 3. AI Sections ✅ DECIDED (strip layout) — sub-questions open

The card boxes are gone. Each AI is now a single compact row inside a shared strip container. Three sub-questions remain:

---

**A: Visibility — Always visible** ✅
Both rows shown at all times. The strip is compact enough that both rows together take less space than one old card row.

**B: Active indicator — Accent row background** ✅
Light grey tint on the active AI's row. Not full black — that's too heavy for a compact strip.

**C: Set progress — Dots with number (●5 ●8 ○)** ✅
Knowing which numbers an AI has collected is strategically useful. Dots with inline number are compact and informative.

**Final strip layout:**
```
┌──────────────────────────────────────┐
│  AI 1  ●5 ●8 ○   7 cards  [Hi][Lo]  │
├ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┤
│  AI 2  ●3 ○ ○    9 cards  [Hi][Lo]  │  ← light grey tint (active)
└──────────────────────────────────────┘
  [Hi][Lo] buttons only shown on your turn
```

---

### 4. Middle Pile

Current: 3-column grid of tappable cards. Starts at 9 cards (3 rows of 3). Cards flip face-up when revealed and back face-down if no set is formed. Cards are permanently removed only when they're part of a collected set, so the pile shrinks irregularly — could lose 0, 1, 2, or 3 cards per set depending on where each card came from.

---

**A: Grid size — Fixed 3×3** ✅
Always show 9 slots. Empty slots (cards already collected into sets) rendered as faint dashed outlines. Layout height never shifts.

**B: Card appearance — Stronger face-down style** ✅
Face-down cards use a dark grey/charcoal back with no text. Face-up (revealed) cards go white with the number. The contrast between the two states is now clear at a glance.

**C: Label — Removed** ✅
No "MIDDLE PILE • N cards" label. The fixed grid is self-evident; empty slots communicate the pile draining.

**Final middle pile layout:**
```
┌──────────────────────────────────┐
│  [███]    [███]    [███]         │  face-down (dark back)
│  [ 5 ]    [███]    [   ]         │  face-up (white) / empty slot (faint outline)
│  [   ]    [   ]    [   ]         │  empty slots
└──────────────────────────────────┘
```

---

### 5. Sets + Log Row

Current: fixed-width sets panel (140px) on the left showing all 3 players' set progress with number chips. Game log takes the remaining width, showing the latest event as a single line of text at 13px.

**Important overlap with decision #3:** The opponents strip now shows AI set progress (●5 ●8 ○). This makes the sets panel largely redundant for AI 1 and AI 2. The only unique info it has is *your* set progress.

---

**A: Sets panel — Removed** ✅
AI set progress lives in the opponents strip. Your set progress moves into the hand section header alongside "YOUR HAND". No dedicated panel.

**B: Game log — Full-width, slightly taller** ✅
With the panel gone the log takes the full width. Slightly increased height so longer messages aren't cramped. Single current event only — no history.

**Final layout:**
```
┌──────────────────────────────────┐
│  🔥 MATCH! Both 7. Find the 3rd! │  full-width, slightly taller
└──────────────────────────────────┘
┌──────────────────────────────────┐
│  YOUR HAND  ●5 ●8 ○  ← YOUR TURN│  set progress inline in header
│  [1][3][4][6][7][9]              │
└──────────────────────────────────┘
```

---

### 6. Your Hand ✅ DECIDED (fan layout)

Cards fan out in a semi-circle arc instead of a flat Wrap. Section is larger than current. The rest of the visual style (dark background, always show card values, amber highlight for already-revealed cards) stays the same.

**Implementation notes:**
- Uses a `Stack` with `Transform.rotate` and manual positioning per card
- Cards positioned along a circular arc whose center point is below the widget
- Each card rotated by its angle along the arc
- Total angle spread and arc radius are the key tuning values

**A: Fan spread — Medium (~70° total, -35° to +35°)** ✅
Wide enough to feel like a real hand, outer cards still readable.

**B: Tappable card lift — Lift all tappable cards** ✅
All unrevealed cards shift upward slightly on your turn to signal they're actionable.

**C: Revealed card treatment — Amber highlight, no lift** ✅
Already-revealed cards keep the amber color but don't get the lift. Colour alone is enough to distinguish them.

**Final hand layout:**
```
        [3]  [5]  [7]  [9]          ← lifted (tappable)
      [2]               [10]
    [1]                   [11]       ← outer cards at ~±35°
         ●5 ●8 ○  YOUR HAND         ← set progress + label in header
```

---

### 7. Game Over State

Current: a black bar appends below the hand with "🏆 YOU WIN!" / "😢 AI WINS!" and PLAY AGAIN + MENU buttons.

**New constraint from decision #6:** The fan hand arcs downward at the edges. A bar below the fan would sit awkwardly underneath the arc — there may not be clean space for it. The inline approach no longer fits naturally.

---

**Options:**

| Option | Description | Tradeoff |
|--------|-------------|----------|
| **Full-screen overlay** | Semi-transparent dark overlay covers the board, centered card shows result + buttons | Dramatic, board stays visible underneath, clear game-end signal |
| **Dedicated screen** | `Navigator.push` to a separate game over screen | Most room for content, clean separation, but loses the board context |
| **Bottom sheet** | Slides up over the bottom of the screen (over the hand) | Less jarring than full overlay, but partially hides the hand |
| **Keep inline bar** | Bar stays below the fan | Awkward with fan layout, cramped |

**Decision: Full-screen overlay** ✅
Semi-transparent dark overlay covers the board. Centered card shows winner message, PLAY AGAIN, and MENU buttons. Board stays visible underneath.

---

### 8. Menu Screen

Current: centered title ("TRIPLE SEVEN", 56px bold) + subtitle + two buttons (PLAY, HOW TO PLAY) with spacers above and below. Pure white, no decoration.

---

**A: Decoration — Card fan of three 7s** ✅
A small decorative fan of three cards (all showing 7) sits between the title and the buttons. Ties the menu to the game's visual style and references the name directly.

**B: Stats — None** ✅
Keep it clean, nothing stored or displayed.

**C: Layout — Title top, buttons bottom** ✅
Title and fan near the top, buttons anchored to the bottom. Classic game menu feel.

**Final menu layout:**
```
┌──────────────────────────────────┐
│                                  │
│        TRIPLE                    │
│        SEVEN          (top)      │
│    A card game for 3 players     │
│                                  │
│         [7] [7] [7]              │  ← decorative fan of three 7s
│        (small card fan)          │
│                                  │
│                                  │
│                                  │
│         [ PLAY ]                 │  ← buttons anchored to bottom
│       [ HOW TO PLAY ]            │
│                                  │
└──────────────────────────────────┘
```

---

## Decisions

_(Fill in as we discuss)_

| # | Area | Decision |
|---|------|----------|
| 1 | Overall layout | Opponents strip — both AIs in one compact row, no card boxes |
| 2 | Turn banner | |
| 3 | AI sections | Compact strip, always visible, accent tint for active row, dots with number for sets |
| 4 | Middle pile | Fixed 3×3 grid, dark face-down backs, no label |
| 5 | Sets + log | Remove sets panel, your sets move to hand header, log goes full-width slightly taller |
| 6 | Your hand | Fan arc (~70°), tappable cards lift, revealed cards amber no lift |
| 7 | Game over | Full-screen overlay, board visible underneath, centered result card |
| 8 | Menu screen | Card fan of three 7s as decoration, no stats, title top + buttons bottom |
