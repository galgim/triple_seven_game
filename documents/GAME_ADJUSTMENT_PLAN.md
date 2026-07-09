# Triple Seven — Game Adjustment Plan

A living doc for gameplay changes. Add new items at any time; mark decisions when settled.

---

## 1. AI Transparency in the Log

**Problem:** When the AI reveals a card from another player's hand, the game log doesn't give the player enough context to understand why — they can't tell what the AI already holds or what it's hunting for.

**Change:** When the AI reveals a card (from any source), the log entry should also mention the card the AI is "playing toward" — specifically, if the AI has already revealed one card this turn, the log should show what number it matched with. If the AI pulls from its own hand during a bonus turn, the log should clearly call that out (e.g. "AI 1 found a 7 in their own hand!").

**Goal:** Player can follow the AI's thought process turn by turn.

---

## 2. AI Thinking Phase (Slower, Visible Turns)

**Problem:** The AI acts too fast. Moves happen in quick succession and the player can't track what's going on.

**Change:** Add a visible "thinking" phase at the start of each AI turn:
- Brief pause (e.g. 600–800ms) before the AI makes any move, shown in the log as "AI 1 is thinking..."
- Each reveal within the AI's turn is spaced out more (increase delays between picks)
- After the turn ends, a short pause before handing back to the next player

**Goal:** The player feels like they're watching an opponent make decisions, not just seeing the board change instantly.

---

## 3. Player Hand Fills the Screen More

**Problem:** The fan hand at the bottom feels too small — cards are compact and the overall hand area doesn't feel prominent enough.

**Change:** Make the hand section take up more vertical space. Options to try:
- Increase fan radius (currently 200) so the arc is wider and cards spread more
- Increase card size (`_CardSize.large` dimensions)
- Increase the container's bottom padding or minimum height

**Goal:** The hand feels like the focal point of the screen — big, tactile, easy to tap.

---

## 4. Revealed Cards Display (Dead Space Between Log and Middle Pile)

**Problem:** The `Spacer` between the middle pile and the game log is wasted screen real estate. The player has no persistent visual of what cards have been revealed so far this turn — they have to read the log text and remember.

**Change:** Replace the `Spacer` with a small "revealed this turn" zone that shows face-up cards as they get revealed, for both the player's turn and the AI's turn. Clears at the start of each new turn.

**Details:**
- Shows up to 3 cards (the maximum that can be revealed in a bonus turn)
- Cards appear one at a time as reveals happen, not all at once
- Same card widget style as the rest of the game (white face-up, amber if already part of a match)
- When no cards have been revealed yet (start of turn), the zone is empty or shows a faint placeholder row
- Clears when `_resetTurnCounters()` is called (i.e. when the next turn begins)

**Data source:** `_gs.revealedCards` / `_gs.revealedThisTurn` — already available in GameState, no new state needed.

**Goal:** Player can glance at the board and instantly see what's been revealed this turn without parsing the log text.

---

## 5. Middle Pile Card Size — Match the Hand Cards

**Problem:** The middle pile cards use `_CardSize.medium` which expands to fill the full column width, making them wide and squat. The hand cards are portrait-oriented (taller than wide, 50×68). The two areas feel visually disconnected.

**Change:** Make the middle pile cards the same dimensions as the hand cards (`_CardSize.large`, 50×68) so they share the same portrait proportion. The 3×3 grid should center the cards in each column rather than stretching them.

**Implementation note:** Currently `_CardSize.medium` has `w: null` (expands) and `h: 64`. The grid uses `Expanded` per column which causes the stretch. Switch to a fixed-width card centered inside each `Expanded` column using `Center` + `NanaCardWidget` with `size: _CardSize.large`. Empty slots (`_EmptySlot`) should match the same 50×68 dimensions.

**Goal:** Consistent card language across the whole board — middle pile, revealed row, and player hand all use the same portrait card shape.

---

## 6. Visual Indicator on AI Strip for Cards Revealed from Their Hand

**Problem:** When an AI reveals a card from their own hand (either during a normal pick or a bonus turn), there's no visual feedback in the opponents strip — the player only sees it in the log text and the revealed cards zone. The AI row feels static.

**Change:** When an AI reveals a card that comes from their own hand, briefly show that card face-up inside their row in the opponents strip. It should appear alongside or below the name/dots/count row while it's revealed, then disappear when the card is flipped back or the turn ends.

**Details:**
- Only appears for cards revealed from the AI's own hand (not middle pile, not another player's hand)
- Uses `revealedThisTurn` — filter for entries where `owner == ai && !fromMiddle`
- Card shown face-up (value visible) in the AI's row, small size so it fits in the strip
- Disappears naturally when `revealedThisTurn` clears at turn end
- No change needed when the AI reveals from the middle pile or from the human's hand — those already appear in the revealed cards zone

**Goal:** Player can see at a glance what card the AI exposed from their own hand, making the AI feel more like a real opponent with a visible hand.

---

## 7. AI Strip — Static Height (No Jarring Expansion)

**Problem:** When an AI reveals a card from their own hand, the revealed card row appears below the info row, causing the strip to expand in height. This jump is jarring and shifts the entire layout.

**Change:** Give each AI row a fixed minimum height that already accounts for the card row space, so it's always reserved whether or not a card is showing. The card slot is always there — empty when no reveal has happened, filled when one has.

**Goal:** The strip never changes size during gameplay. Layout stays stable.

---

## 8. Middle Pile — Cards Closer Together and Slightly Bigger

**Problem:** The middle pile cards are spaced too far apart from each other in the 3×3 grid, making it feel loose and spread out.

**Change:**
- Reduce horizontal padding between cards (currently `horizontal: 3` in each column's `Padding`)
- Slightly increase card size beyond the current `_CardSize.large` (50×68) — try 56×76 or similar
- Update `_EmptySlot` to match the new dimensions

**Goal:** The pile feels dense and compact — like a real stack of cards laid out in a grid.

---

## 9. Player Hand — Bigger Cards, Flatter Fan

**Problem:** The fan spread is too pronounced and the cards could be larger. The current 70° arc makes the outer cards feel far from the center and hard to tap comfortably.

**Change:**
- Reduce total fan angle (currently 70°) — try 45–50° for a flatter, more natural spread
- Increase card size (currently 50×68) — try 58×80 or similar
- Adjust radius and lift amounts to match the new card size

**Goal:** Cards feel large and easy to tap. The fan is still visible as a fan but doesn't arc so aggressively at the edges.

---

## 10. Middle Pile — 5+4 Layout Instead of 3×3

**Problem:** The 3×3 grid feels forced and geometric — it doesn't look like a natural card spread. The equal spacing in every direction makes it feel like a UI table rather than a pile of cards.

**Change:** Reorganize the 9 slots into two rows: 5 cards on top, 4 cards on the bottom row. Both rows are centered, so the bottom row naturally sits offset between the top row's gaps — giving a more organic, staggered feel.

**Implementation:** Replace the `List.generate(3, (row) => ...)` loop in `_MiddleSection` with two hardcoded `Row` widgets — first using indices 0–4, second using indices 5–8. Keep `mainAxisAlignment: MainAxisAlignment.center` on both.

**Goal:** The middle pile looks like a spread of cards, not a grid.

---

## 11. Revert Player Hand to Previous Fan Settings

**Problem:** The item 9 changes (50° angle, 58×80 cards) made the hand too large and the fan too flat — it lost the fan feel.

**Change:** Revert `_FanHandSection` constants and `_CardSize.large` back to the pre-item-9 values:
- Angle: 70° (was changed to 50°)
- Card size: 50×68 (was changed to 58×80)
- Radius: 230 (was changed to 240)
- Lift: 16px (was changed to 18px)
- Font size: 17 (was changed to 19)

**Goal:** Restore the hand feel from before item 9.

---

## 12. Player Hand — Only Highest and Lowest Cards Are Tappable

**Problem:** The player can tap any card in their hand to reveal it, which is too permissive. The game should restrict own-hand reveals the same way the AI does it — high or low only.

**Change:** In `_FanHandSection`, compute the lowest and highest unrevealed card objects among `human.hand` (which is already sorted ascending). Only those two card instances get `isTappable = true`. All other face-down cards in the hand are rendered non-tappable (dimmer border, no shadow).

**Implementation:** Before the `List.generate` loop, filter `human.hand` by `!c.faceUp` to get `unrevealed`. The lowest is `unrevealed.first`, the highest is `unrevealed.last` (or the same if only 1 card). Identity comparison (`card == lowestCard || card == highestCard`) works since `NanaCard` does not override `==`.

**Goal:** Player is subject to the same high/low restriction as the AI's opponent picks.

---

## 13. Triple Seven Instant Win

**Problem:** The game currently only ends when a player collects 3 sets. There's no special rule for the 7s.

**Change:** If any player collects a set of three 7s, the game ends immediately — even if they don't have 3 total sets. This check runs in `_collectSet` in `game_state.dart`, right after adding to `collector.sets`, before the normal 3-sets win check.

**Win message:** `'🎰 ${collector.name} wins with Triple Seven!'`

**Goal:** Collecting the 7s is a special instant-win condition that adds a secondary objective to the game.

---

## 14. Remove AppBar Title

**Problem:** The "TRIPLE SEVEN" AppBar at the top of the game screen wastes ~44px of vertical space and adds unnecessary chrome — the game doesn't need a title bar while you're playing.

**Change:** Remove the `AppBar` from the `Scaffold` entirely. The body fills top-to-bottom, bounded by `SafeArea`.

**Implementation:** Delete the `appBar:` property (lines 41–50 in `game_screen.dart`). No other changes needed — `SafeArea` already handles the status bar.

**Goal:** Cleaner, more immersive screen. Reclaims vertical space for the game board.

---

## 15. Remove Turn Banner

**Problem:** The instruction banner below the AppBar ("👆 Pick 1 of 2 — High/Low from AI or tap middle", "AI 1's turn...", "🔥 BONUS!...") is verbose and clutters the top of the screen. The game state is already communicated by the board itself.

**Change:** Remove `_buildTurnBanner` and its helper method entirely. Also remove the `_gs.gameLog` call and `SizedBox(height: 6)` that follow it in the Column in `build()`.

**Implementation:**
- In `build()`, delete `_buildTurnBanner(isYourTurn)` and the `SizedBox(height: 6)` after it (lines 59–60)
- Delete the `_buildTurnBanner` method (lines 113–141)

**Goal:** Top of the screen is immediately the opponents strip — no text instructions between the edge and the board.

---

## 16. Remove Game Log

**Problem:** The `_GameLogWidget` above the player's hand is a text block that narrates every move. With the AI thinking phase slowing things down and the revealed cards row showing what was picked, the log adds noise rather than clarity.

**Change:** Remove `_GameLogWidget` from the Column in `build()`. Keep `_gs.gameLog` in `GameState` untouched — only the UI widget is removed.

**Implementation:** Delete `_GameLogWidget(gameLog: _gs.gameLog)` (line 87 in `game_screen.dart`). The `_GameLogWidget` class itself can stay or be deleted — either way, it won't render.

**Goal:** The space between the revealed cards row and the player's hand is clean — no text block breaking up the layout.

---

## 17. Settings Button with Pause Popup

**Problem:** Removing the AppBar also removed the back button, so the player has no way to return to the main menu mid-game.

**Change:** Add a small settings/pause icon button to the game screen that opens a modal popup. The popup contains at minimum a "Back to Menu" action. It should feel like a light pause sheet, not a full screen takeover.

**Placement:** Top-right corner of the game screen, overlaid on the board using the existing `Stack` in `build()`. A small `⚙` or `✕` icon button, black on white or white on black to match the board aesthetic.

**Popup behavior:**
- Opens with `showDialog` (or a bottom sheet — TBD on feel)
- Contains: a "Back to Menu" button that calls `Navigator.pop(context)` to return to the menu, and a "Resume" / dismiss option to close the popup and continue playing
- Does not reset game state — just navigates away if the player chooses to

**Implementation:**
- In `build()`, add a `Positioned(top: 8, right: 8, child: _SettingsButton(...))` inside the `Stack`
- `_SettingsButton` is a small `GestureDetector` wrapping an icon or label, calls `showDialog` on tap
- The dialog is a simple `AlertDialog` or custom `Dialog` widget with the two actions

**Goal:** Player can always exit to the menu without force-quitting the app, even with no AppBar.

---

## 18. Redesign AI Opponents as Side-by-Side Card Profile Icons

**Problem:** The current opponents strip is two stacked text rows — name, dots, card count, and Hi/Lo buttons. It reads like a scoreboard, not like opponents sitting across from you.

**Change:** Replace `_OpponentsStrip` and `_AIRow` with two rectangular profile cards sitting side by side in a `Row`. Each card:
- 3 decorative face-down card shapes above the profile icon — always 3, purely visual, not tied to actual hand count
- A person silhouette icon (`Icons.person`) centered below the decorative cards
- AI name and set dots below the icon
- Hi and Lo buttons pinned to the bottom of the card, always rendered (greyed out when not usable)

**Layout sketch:**
```
┌───────────────┐  ┌───────────────┐
│  [🂠] [🂠] [🂠] │  │  [🂠] [🂠] [🂠] │
│      👤       │  │      👤       │
│  AI 1  ●5 ○   │  │  AI 2  ○ ○   │
│  [Hi]   [Lo]  │  │  [Hi]   [Lo] │
└───────────────┘  └───────────────┘
```

**Details:**
- Both cards are equal width with a small gap (`Row` with two `Expanded` children and `SizedBox(width: 8)` between)
- Decorative cards: 3 small face-down `Container` rectangles with rounded corners and a dark fill, arranged in a `Row` centered in the card
- Active player highlight: slightly grey background on their card (`Colors.grey.shade100`), white when inactive
- **Hi/Lo buttons always rendered** — when `!canReveal || ai.hand.isEmpty`, buttons are greyed out (pass `onTap: null` to `_ActionButton`, which already renders grey when null)
- **No revealed card slot in the AI strip** — AI own-hand reveals go to the revealed cards zone below the middle pile (see item 18b below), keeping the strip fully static height

**Implementation:** Replace `_OpponentsStrip` + `_AIRow` with `_OpponentsRow` (a `Row` of two `_AIProfileCard` widgets). Remove `ownRevealedCards` / `revealedThisTurn` filtering from the strip entirely.

**Goal:** Opponents feel like players, not a data table. Layout never shifts.

---

## 18b. Revealed Cards Zone — Always Visible, Bigger Cards

**Problem:** `_RevealedCardsRow` returns `SizedBox.shrink()` when empty, causing a layout shift when the first card is revealed. Cards also use `_CardSize.medium` which is too small to read at a glance.

**Change:** Always reserve space for the revealed cards zone. Show a fixed-height placeholder row when empty, and big cards when cards are present.

**Details:**
- Fixed height always — use a `SizedBox(height: 90)` wrapper around the row content so nothing shifts
- Cards use `_CardSize.pile` (56×76) — same as middle pile cards, large and legible
- When empty: show nothing inside the reserved space (just blank)
- When cards present: show them centered in the zone as before
- AI own-hand reveals now appear here too (they're already in `revealedThisTurn` — no data change needed)

**Implementation:** Remove the early `if (revealedThisTurn.isEmpty) return SizedBox.shrink()` guard. Wrap the `Center(child: Row(...))` in a `SizedBox(height: 90, child: ...)`. Change `_CardSize.medium` to `_CardSize.pile` for the card widgets inside.

---

## 19. Layout — AI Cards Down, Middle Centered, Hand Pinned to Bottom

**Problem:** After removing the AppBar, banner, and log, all content stacks from the top — the AI cards overlap the settings cog, the middle pile is too high, and the player hand floats up rather than sitting at the bottom of the screen.

**Change:** Restructure the Column layout so:
1. AI cards sit below the settings cog (add top padding to the outer `Padding` to clear the ~34px cog button)
2. Middle pile + revealed cards zone are vertically centered in the remaining space between the AI strip and the player hand
3. Player hand is pinned to the very bottom

**Implementation:**
- Change outer `Padding` from `EdgeInsets.fromLTRB(8, 6, 8, 6)` to `EdgeInsets.fromLTRB(8, 48, 8, 6)` — the extra top padding clears the settings cog
- Remove the `SizedBox(height: 6)` spacer between the AI row and middle section (no longer needed; the Expanded handles spacing)
- Wrap `_MiddleSection` and `_RevealedCardsRow` together in an `Expanded` child with a `Column(mainAxisAlignment: MainAxisAlignment.center)` — this centers the pile + reveal zone in the available vertical space
- `_FanHandSection` stays as the last child and naturally pins to the bottom

**Column structure after change:**
```
Column:
  ├─ _OpponentsRow          ← sits below cog thanks to top padding
  ├─ Expanded               ← fills all remaining space
  │   └─ Column(center)
  │       ├─ _MiddleSection
  │       └─ _RevealedCardsRow
  └─ _FanHandSection        ← pinned to bottom
```

**Goal:** Screen feels intentionally laid out — opponents at top, board in the middle, hand at the bottom. No overlaps, no wasted space.

---

## 20. Player Hand — Bigger Cards, Corner Numbers, Tighter Fan

**Problem:** The hand label wastes space, cards are too small to feel like the focal point, and with bigger cards the fan needs to tighten so everything fits on screen while still showing the identifying corner of each card.

**Changes:**

1. **Remove "YOUR HAND / YOUR HAND ← YOUR TURN" label** — delete the `Row` containing the text. Keep `_SetDots` on its own row so the player can still see their set progress.

2. **Corner number on hand cards** — `NanaCardWidget` currently shows one centered number. For `_CardSize.large` only, add a second smaller number at the top-left corner using a `Stack`: `Positioned(top: 4, left: 5)` with a smaller font (11–12px). The center number stays. Corner number only shows when `showValue` is true (same condition as center number).

3. **Bigger cards** — increase `_CardSize.large` from 50×68 to 64×88. Update `_cardW` and `_cardH` constants in `_FanHandSectionState` to match.

4. **Tighter fan** — reduce `_totalAngle` from 70° to 50°. With 9 cards at 50° total (6.25° per step), each card shows ~25px of its left edge from under the next card — enough to read the corner number. The arc is flatter and the hand feels more compact and deliberate.

**Fan constants after change:**
- `_radius`: 230 (unchanged)
- `_totalAngle`: 50° (was 70°)
- `_cardW`: 64 (was 50)
- `_cardH`: 88 (was 68)
- `_liftAmount`: 16 (unchanged)

**Goal:** The hand dominates the bottom of the screen. Cards are big and readable. The fan is tight enough to see every card's corner number without the spread feeling chaotic.

---

## 21. AI Profile Card — Real Card Count, Reorganised Layout

**Problem:** The 3 decorative cards are purely visual and don't convey real info. The set dots are below the icon alongside the name, and there's no visible card count.

**Change:** Reorganise the `_AIProfileCard` layout:
1. Remove the 3 decorative face-down card rectangles entirely
2. Move `_SetDots` to above the person icon
3. Keep name below the icon (unchanged)
4. Add actual card count (`'${ai.handCount} cards'`) right above the Hi/Lo buttons

**New layout top-to-bottom:**
```
_SetDots          ← moved up, above icon
Icon(person)
Text(ai.name)
'X cards'         ← new, actual hand count
[Hi]  [Lo]
```

**Implementation:** In `_AIProfileCard.build()`:
- Delete the `Row` of 3 decorative card containers and its `SizedBox(height: 6)` below it
- Move `_SetDots(player: ai)` and its `SizedBox(height: 2)` to before `Icon(Icons.person...)`
- Add a `Text('${ai.handCount} cards', style: small grey)` + `SizedBox(height: 8)` between the name and the Hi/Lo button row
- Remove the old `SizedBox(height: 8)` that was between `_SetDots` and buttons (now replaced by the one after card count)

**Goal:** The AI card shows real information at a glance — how many cards they hold and how many sets they have — without decorative filler.

---

## 22. AI Profile Card — Show Real Hand Cards with Hi/Lo Highlight

**Problem:** The "X cards" text tells the player a number but shows nothing visual. The player can't see which card would be picked when they press Hi or Lo.

**Change:** Replace the card count text with a physical grid of all cards in `ai.hand`, arranged in a 5-top / rest-bottom layout (same pattern as the middle pile). Cards are face-down by default. When a card is revealed (after pressing Hi or Lo), it flips face-up with an amber highlight in the AI's hand display — the player can see exactly which card was taken.

**Card display rules:**
- Face-down (`!card.faceUp`): dark rectangle, no value shown
- Face-up (`card.faceUp`): white with value centered
- Highlighted (`revealedCards.contains(card)`): amber background + orange border (same as rest of game)

**Layout:**
- Cards arranged in rows of 5 (top) + remainder (bottom row, centered)
- Card size: 26×36 (`_CardSize.mini` — new enum value) with font size 13
- 2px horizontal gap between cards, 4px vertical gap between rows
- At 5 cards × 26px + 4 gaps × 2px = 138px — fits within the ~144px inner width of each AI card

**Data flow:**
- Pass `revealedCards: _gs.revealedCards` (a `Set<NanaCard>`) down through `_OpponentsRow` → `_AIProfileCard`
- Use `card.faceUp` for show/hide value; use `revealedCards.contains(card)` for amber highlight

**AI card height:** Let it size naturally (`mainAxisSize: MainAxisSize.min`) — the card grid replaces the single text line and will be taller. Both AI profile cards grow equally so layout stays balanced.

**Implementation:**
- Add `_CardSize.mini` to the enum (w: 26, h: 36, fs: 13)
- In `_OpponentsRow`, add `revealedCards` param and pass to each `_AIProfileCard`
- In `_AIProfileCard`, replace `Text('${ai.handCount} cards')` with a card grid widget using `ai.hand`
- Grid: `Column` of up to two `Row`s — first row indices 0–4, second row indices 5–(n-1), both centered
- Each card: `NanaCardWidget(card: card, darkBg: true, tappable: false, highlighted: revealedCards.contains(card), size: _CardSize.mini)`
- Update call site in `build()` to pass `revealedCards: _gs.revealedCards`

**Button order:** Swap to `[Lo] [Hi]` (Lo on left, Hi on right) so the spatial layout matches the player's fan hand — lowest card is on the left, highest is on the right.

**Goal:** The player can see the AI's full hand and watch the correct card light up amber when they press Hi or Lo — making each pick feel meaningful and legible.

---

## 23. AI Hand — Fan Display Instead of Grid

**Change:** Replace the 5+remainder card grid in `_AIProfileCard` with a small fan arc, matching the player hand style. Cards are face-down by default; revealed cards show their value with amber highlight in place.

**Fan parameters (sized to fit inside the ~148px inner width of each AI profile card):**
- `radius`: 80
- `totalAngle`: 80°
- `cardW/H`: 26×36 (`_CardSize.mini`)
- `liftAmount`: 4

**Implementation:** Remove the `cardRow` helper and grid `Column` children. Replace with a `SizedBox(height: fanHeight)` + `LayoutBuilder` + `Stack` using the same arc math as `_FanHandSection`, but without gesture detection. Each card is a `NanaCardWidget(tappable: false, highlighted: revealedCards.contains(card), size: _CardSize.mini)`.

---

## 24. Middle Pile — Larger Cards to Match Player Hand

**Problem:** The middle pile cards (56×76) are noticeably smaller than the player hand cards (76×104), making them feel like a secondary element rather than the central board.

**Change:** Increase `_CardSize.pile` from 56×76 to 64×88 (font size 18→20). Reduce horizontal card padding from 4 to 1 so the wider cards still fit the 5-card top row. Update `_EmptySlot` to match 64×88. Increase `_RevealedCardsRow` reserved height from 90 to 100 to accommodate the taller cards.

**Goal:** Middle pile cards feel substantial — closer in size to the hand cards, making the board read as one cohesive layout.

---

## 25. AI Hand Fan — Bigger Cards for Visibility

**Problem:** The AI hand fan uses `_CardSize.mini` (26×36) which is too small to read at a glance — the values are barely legible when revealed.

**Options considered:**
- A — 30×42, angle 80° (unchanged): ~15% bigger, still compact
- **B — 34×48, angle 70°: ~30% bigger, angle tightened so wider cards still spread cleanly** ← chosen
- C — 38×52, radius 90, angle 70°: ~46% bigger, nearly fills the AI card edge to edge

**Change (Option B):** Update `_AIProfileCard` fan constants and `_CardSize.mini` dimensions:
- `_fanCardW`: 26 → 34
- `_fanCardH`: 36 → 48
- `_fanAngle`: 80° → 70°
- `_CardSize.mini` in `NanaCardWidget`: w=26→34, h=36→48, fs=11→13

**Goal:** AI hand cards are comfortably readable when revealed — player can see the value without squinting.

---

## 26. Card Back — Navy Fill with White Inset Border

**Change:** Redesign the face-down card back (Option A — tight border):
- Background: navy (`Color(0xFF003087)`)
- Inner border: white 1.5px rectangle, 4px inset from card edges, `BorderRadius.circular(3)`
- Center text: "777" italic bold in white
- Remove: corner dots (`_Dot` class deleted)

**Implementation:**
- `NanaCardWidget.build()`: change face-down color from `darkBg ? grey.shade800 : grey.shade300` to `const Color(0xFF003087)`
- `_CardBack`: remove `darkBg` and `size` params (unused after change), always use `Colors.white` ink, replace 4 dot `Positioned` children with a single `Positioned.fill` + `Padding(4)` + `Container(white border)`
- Delete `_Dot` class

**Call site:** `_CardBack(darkBg: darkBg, fs: fs, size: size)` → `_CardBack(fs: fs)`

---

## 27. AI Hand Fan — Bigger Cards, Remove Person Icon

**Change:** Remove the `Icon(Icons.person)` row from `_AIProfileCard` to free vertical space, and increase `_CardSize.mini` from 34×48 to 50×70. Tighten fan angle from 70° to 65° so wider cards still fit the profile card width.

**Fan constants after change:**
- `_fanCardW`: 34 → 50
- `_fanCardH`: 48 → 70
- `_fanAngle`: 70° → 65°
- `_fanRadius`: 80 (unchanged)
- `_CardSize.mini`: w=50, h=70, fs=17

**Net effect:** Profile card is ~22px shorter than before (icon removal saves 42px; bigger fan adds ~20px). All 9 cards still shown.

**Implementation:**
- Delete `Icon(Icons.person, size: 38)` and the `SizedBox(height: 4)` after it in `_AIProfileCard.build()`
- Update `_fanCardW/H` and `_fanAngle` constants
- Update `_CardSize.mini` fallthrough values in `NanaCardWidget`

---

## 28. Game Screen Background — Light Blue Crosshatch *(superseded by item 29)*

**Note:** Implemented then immediately replaced. Pattern was removed in favour of a solid colour.

---

## 29. Game Screen Background — Solid Maroon *(superseded by item 30)*

**Note:** Implemented then immediately replaced.

---

## 30. Game Screen Background — Light Blue Diamond Pattern, Full Screen

**Change:** Light blue crosshatch (diamond) pattern covering the full screen including behind the status bar.

**Fix vs item 28:** The `CustomPaint` was previously inside `SafeArea`, so the pattern only covered the safe zone. Restructured `body` so `CustomPaint` is a direct child of the outer `Stack` (fills full `body`), and `SafeArea` wraps only the game content on top of it.

**Colors:** Base `Color(0xFFDCF0FB)`, lines `Color(0xFFA8D4F0)`, 0.7px, 24px spacing.

**Body structure after change:**
```
Scaffold.body → Stack
  ├─ Positioned.fill → CustomPaint(_CrosshatchPainter)   ← full screen
  └─ SafeArea → Stack                                    ← game content
       ├─ Padding → Column (game layout)
       ├─ Positioned (settings button)
       └─ _GameOverOverlay (conditional)
```

---

## 31. Turn Indicator — Amber Border (AI) + Amber Pill (Player)

**Change:** Clear, consistent turn signal using the same amber accent color for both sides.

- **Active AI card**: border → `Colors.amber`, 2.5px. Background → plain white (grey.shade100 removed — border alone is sufficient).
- **Inactive AI card**: border → `Colors.black26`, 1px. Visually recedes without dimming.
- **Player's turn**: `_SetDots` row wrapped in an amber rounded-pill container (`Colors.amber` fill, `BorderRadius.circular(12)`, `padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3)`).
- **Player inactive**: plain `_SetDots`, no pill.

**Implementation:**
- `_AIProfileCard.build()`: change `BoxDecoration` color to always `Colors.white`; change border `color` and `width` to `isActive ? Colors.amber : Colors.black26` and `isActive ? 2.5 : 1.0`
- `_FanHandSection.build()`: conditionally wrap `_SetDots` in amber pill container based on `widget.isYourTurn`

---

## 32. Player Name Entry — Menu Screen Field

**Change:** Add a player name text field on the menu screen (above PLAY). Name is passed through to `GameState` and displayed to the left of `_SetDots` in the player's hand section.

**Display:** Name and dots sit together inside the existing amber pill Container in `_FanHandSection` — `Row([ Text(name), SizedBox(6), _SetDots ])`. Pill background is amber on player's turn, transparent otherwise (no layout shift — Container always present).

**Defaults:** Field pre-filled with `'You'`. If left blank on PLAY, falls back to `'You'`.

**Data flow:**
```
MainMenuScreen (TextEditingController)
  → GameScreen(playerName: ...)
    → GameState(playerName: ...)
      → NanaPlayer(name: playerName)
```

**Implementation:**
1. `menu_screen.dart`: Convert to `StatefulWidget`, add `TextEditingController`, add styled `TextField` above PLAY, pass trimmed name to `GameScreen` on PLAY tap
2. `game_screen.dart`: Add `final String playerName` to `GameScreen`, pass to `GameState(playerName: playerName)`
3. `game_state.dart`: Add `final String playerName` constructor param, use in `_init()` for `NanaPlayer(name: playerName, ...)`
4. `game_screen.dart _FanHandSection`: Change Container child from `_SetDots` to `Row([ Text(player.name), SizedBox(6), _SetDots ])`

---

## 33. Menu Card Fan — Light Overlap, Gentle Angle

**Change:** Reduce overlap and fan angle on the three card-back fan on the menu screen.

| Property | Before | After |
|----------|--------|-------|
| `left/right` inset | 44 | 28 |
| `top` offset | 38 | 34 |
| angle | ±0.35 rad (20°) | ±0.25 rad (14°) |
| overlap per side | 32px | 16px |

Stack order unchanged: left, right, center (center on top).

---

## 34. Highlighted Card — Faded Amber Wash + Vivid Border

**Change:** Instead of a solid amber fill on revealed/highlighted cards, use a very light amber tint with a vivid full-opacity amber border.

| Property | Before | After |
|----------|--------|-------|
| Fill | `Colors.amber` (solid) | `Colors.amber.withOpacity(0.20)` |
| Border color | `Colors.orange` | `Colors.amber` |
| Border width | 2.5px | 3.0px |

Number text stays `Colors.black` — clearly readable on the light amber wash.

**Implementation:** Two lines in `NanaCardWidget.build()` `BoxDecoration`.

---

## 35. Revealed Cards Zone — Always-Visible Placeholder Slots

**Problem:** `_RevealedCardsRow` only renders the cards that have actually been revealed this turn — at the start of a turn it's fully blank, giving no indication of where cards will appear or how many can appear (up to 3, for a bonus turn).

**Change:** Always render 3 slots in the revealed-cards zone. Slots not yet filled show a greyish, semi-transparent placeholder in the same size/shape as a real card; as reveals happen, each placeholder is replaced in order by the actual face-up card.

**Options considered:**
- **A — Ghost card (filled wash), chosen:** Rounded rect filled with `Colors.grey.withValues(alpha: 0.18)`, border `Colors.grey.withValues(alpha: 0.45)` at 1.5px. Reads as a translucent "card-shaped hole" waiting to be filled.
- B — Outline only: fully transparent fill, just a `Colors.grey.withValues(alpha: 0.35)` border. Same treatment as the middle pile's `_EmptySlot` but grey-tinted instead of near-black. Lightest-weight option.
- C — Dashed ghost outline: transparent fill with a dashed grey border (`Colors.grey.withValues(alpha: 0.4)`) via a small `CustomPainter`. Reads most clearly as a "drop zone," distinct from the solid borders on real cards.

**Implementation:** `_RevealedCardsRow` now uses `List.generate(3, ...)` instead of mapping only `revealedThisTurn`. Index `i < revealedThisTurn.length` renders the real `NanaCardWidget`; otherwise renders the new `_RevealedSlotPlaceholder` widget (64×88, matching `_CardSize.pile`). Cards fill the slots left-to-right in reveal order, replacing placeholders one at a time rather than all appearing at once.

**Goal:** Player always sees the 3-slot shape of the revealed zone, understands its capacity at a glance, and watches placeholders convert to real cards as the turn progresses.

---

## Backlog / Ideas to Revisit

_(Dump future ideas here before they're ready to be spec'd out)_

---

## Decision Log

| # | Area | Decision | Status |
|---|------|----------|--------|
| 1 | AI log transparency | Implemented 2026-06-22 | Done |
| 2 | AI thinking phase | Implemented 2026-06-22 | Done |
| 3 | Player hand size | Implemented 2026-06-22 | Done |
| 4 | Revealed cards display | Implemented 2026-06-22 | Done |
| 5 | Middle pile card size | Implemented 2026-06-22 | Done |
| 6 | AI strip hand reveal indicator | Implemented 2026-06-22 | Done |
| 7 | AI strip static height | Implemented 2026-06-22 | Done |
| 8 | Middle pile spacing + size | Implemented 2026-06-22 | Done |
| 9 | Player hand bigger + flatter fan | Implemented 2026-06-22 | Done |
| 10 | Middle pile 5+4 layout | Implemented 2026-06-22 | Done |
| 11 | Revert player hand to pre-item-9 | Implemented 2026-06-22 | Done |
| 12 | Player hand high/low only | Implemented 2026-06-26 | Done |
| 13 | Triple Seven instant win | Implemented 2026-06-26 | Done |
| 14 | Remove AppBar title | Implemented 2026-06-29 |
| 15 | Remove turn banner | Implemented 2026-06-29 |
| 16 | Remove game log | Implemented 2026-06-29 |
| 17 | Settings button + pause popup | Implemented 2026-06-29 |
| 18 | AI opponents as side-by-side profile cards | Implemented 2026-06-29 |
| 18b | Revealed cards zone — always visible, bigger | Implemented 2026-06-29 |
| 19 | Layout — AI down, middle centered, hand bottom | Implemented 2026-06-29 |
| 20 | Player hand — bigger cards, corner numbers, tighter fan | Implemented 2026-06-29 |
| 21 | AI profile card — real card count, reorganised layout | Implemented 2026-06-29 |
| 22 | AI profile card — real hand cards with hi/lo highlight | Implemented 2026-06-29 |
| 23 | AI hand — fan display instead of grid | Implemented 2026-06-29 |
| 24 | Middle pile — larger cards (64×88) to match hand | Implemented 2026-07-02 |
| 25 | AI hand fan — bigger cards 34×48, angle 70° | Implemented 2026-07-02 |
| 26 | Card back — navy + white inset border, remove dots | Implemented 2026-07-03 |
| 27 | AI hand fan — 50×70 cards, remove person icon | Implemented 2026-07-03 |
| 28 | Game screen background — light blue crosshatch | Superseded by #29 |
| 29 | Game screen background — solid maroon #8B2020 | Superseded by #30 |
| 30 | Game screen background — light blue diamond, full screen | Implemented 2026-07-03 |
| 31 | Turn indicator — amber border (AI) + amber pill (player) | Implemented 2026-07-03 |
| 32 | Player name entry — menu field, shown left of set dots | Implemented 2026-07-03 |
| 33 | Menu card fan — light overlap, angle ±0.25, left/right: 28 | Implemented 2026-07-03 |
| 34 | Highlighted card — faded amber wash + vivid amber border | Implemented 2026-07-03 |
| 35 | Revealed cards zone — 3 always-visible grey ghost placeholder slots | Implemented 2026-07-08 |
