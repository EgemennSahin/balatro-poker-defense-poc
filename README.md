# Poker Defense POC

A small Balatro + tower defense proof of concept built as a Steamodded mod. It tests one question: **does playing poker hands to activate a lane of card towers feel fun?**

## Prototype loop

- Buy the Common **Lane Commander** Joker to start the prototype.
- The first 8 unique cards in your scoring hands fill 8 fixed tower slots.
- Playing those physical cards activates their tower. Rank sets damage; suit adds an effect.
- Enemies move along a single 8-slot lane. Leaks reduce your 10 lives.
- Five waves use normal, fast, armored, mixed, and boss enemies.
- The lane is drawn on the Joker card with no custom art. Run the normal Balatro blind at the same time; lane damage also adds chips.

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

This prototype keeps vanilla scoring and the shop. Towers are created automatically in the order cards first score, so there is no placement screen.

## Install

1. Install Lovely and Steamodded for your Balatro version.
2. Copy `main.lua`, `mod.json`, and `lovely.toml` into `%AppData%\Balatro\Mods\PokerDefensePOC\`.
3. Launch Balatro. Buy **Lane Commander** from the Joker shop and play scoring hands.

The lane state is stored in `G.GAME` and should follow the run save. Debug events are tagged `PokerDefense` in the Lovely log. `lovely.toml` contains compatibility patches for the old local game build.

## Scope

This is a mechanic test, not a full tower defense game or a Bloons TD 6 clone. It has one Joker, one lane, eight slots, three regular enemy types plus a final boss, and five waves. It has no custom art, branching maps, manual tower placement, or expanded content.

## Verification

The mod loaded successfully to the main menu on Balatro 1.0.0i with the local Steamodded 26.829.0 setup while Evolutionary Deck was disabled. The complete lane loop has not yet been played through. This machine has separate compatibility adjustments to the installed Steamodded files; those adjustments are not included here, and a clean install on a newer Balatro/Steamodded pair remains unverified.
