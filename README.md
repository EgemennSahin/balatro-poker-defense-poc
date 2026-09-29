# Tower Defense MVP

A tiny tower defense game inside Balatro. Choose the **Tower Defense** deck when you start a run; it starts the defense board for you.

## Prototype loop

- Choose the **Tower Defense** deck. It starts with the Defense Board Joker, which is the lane display and game controller.
- The first 8 unique cards in your scoring hands fill 8 fixed tower slots.
- Playing those physical cards activates their tower. Rank sets damage; suit adds an effect.
- Enemies move along a single 8-slot lane. Leaks reduce your 10 lives.
- Five waves use normal, fast, armored, mixed, and boss enemies.
- The lane and enemy are drawn on the Defense Board with no custom art. Played hands operate the defense; lane damage also adds chips.

### Card and hand effects

| Card or hand | Effect |
| --- | --- |
| Rank | Base damage equals rank value |
| Spades | Ignore armor |
| Clubs | +3 damage to fast enemies |
| Hearts | Restore 1 life on a kill, up to 10 |
| Diamonds | Earn $1 on a kill |
| Pair / Two Pair / Three of a Kind / Full House / Four of a Kind | +2 damage per shot |
| Straight | +2 damage per shot |
| Flush | +2 damage per shot |

Towers are created automatically from the first 8 unique cards that score, so there is no placement screen. The Defense Board is hidden from ordinary Joker pools; use the Tower Defense deck to launch this mode.

## Install

1. Install Lovely and Steamodded for your Balatro version.
2. Copy `main.lua`, `mod.json`, and `lovely.toml` into `%AppData%\Balatro\Mods\PokerDefensePOC\`.
3. Launch Balatro, choose **New Run**, then select the **Tower Defense** deck in the deck picker.

The lane state is stored in `G.GAME` and should follow the run save. Debug events are tagged `PokerDefense` in the Lovely log. `lovely.toml` contains compatibility patches for the old local game build.

## Scope

This is a mechanic test, not a full tower defense game or a Bloons TD 6 clone. It has one Joker, one lane, eight slots, three regular enemy types plus a final boss, and five waves. It has no custom art, branching maps, manual tower placement, or expanded content.

## Verification

The mod loaded successfully to the main menu on Balatro 1.0.0i with the local Steamodded 26.829.0 setup while Evolutionary Deck was disabled. The complete lane loop has not yet been played through. This machine has separate compatibility adjustments to the installed Steamodded files; those adjustments are not included here, and a clean install on a newer Balatro/Steamodded pair remains unverified.
