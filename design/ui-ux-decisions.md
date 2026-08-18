# Final Lap · Final Race — UI/UX Decisions

**Date:** 2026-08-18 · **Art direction:** Retro Carnival
**Prototype:** `design/ui-prototype.html` · **Game language:** English (ship-first locale)

## Art direction
Carnival tent (red/cream stripes), wooden midway board, bulb-lit marquee signage, night palette.
Sits well with the existing pixel-art horse sprites; every surface reads as "inside the tent".

## Palette
| Role | Hex |
|---|---|
| Night (backdrop) | `#150F0E` |
| Tent (deep maroon) | `#2B1712` |
| Wood board | `#4A2C1A` |
| Cream / Parchment | `#F8EDD6` / `#E9D5AC` |
| Carnival Red (6 pts) | `#C8352C` |
| Marquee Gold (3 pts) | `#F5B942` |
| Green (2 pts) | `#46A055` |
| **Player Teal** | `#2E8C7E` |

**Rule:** Teal belongs to the player and nothing else — no decorative use.
The StyleBoxFlat colours already in `ScoringBoard.tscn` should be updated to these values.

## Typography
- Display: **Alfa Slab One** (titles, win/lose)
- Marquee: **Bungee** (buttons, HUD, scores) — uppercase-only by design
- Body: **Rubik** (body copy, settings, legal)
- Ship English first, but import fonts with **Latin Extended-A** included — nearly free now, saves a re-export when localising.

Scale (on the 1080×1920 canvas): Display XL 96 / Display 72 / Heading 48 / Button 42 / Body 34 / Caption 28 / Legal 24 px.

## Screen inventory (12)
01 Splash · 02 Main Menu · 03 Consent (GDPR/ATT/UMP) · 04 Sign In · 05 Level Map ·
06 Race Setup · 07 Gameplay · 08 First-Run Coaching · 09 Pause · 10 Victory · 11 Defeat · 12 Settings

## Key UX decisions
- **Thumb law:** the bottom 35% of the screen belongs to the player alone. No button, ad or toast there, ever.
- **Screen split:** top 40% race track, bottom 60% scoring board (matches the existing `Main.tscn` split).
- **Two distinct scores:** "points" on the HUD bar, "distance" on the track — they must never look alike.
- **Rival visibility:** show only the lead rival in the HUD, not all four.
- **No separate tutorial:** level 1 *is* the tutorial. Teach with light and motion, not a wall of text.
- **The losing beat:** delay the defeat screen 800 ms so the player sees on the track why they lost. Tone is coaching, not blaming.
- **Android back button:** defined on every screen — Pause during a race, exit confirmation in the menu.
- **Holes are never distinguished by colour alone:** size (90/120/150 px) plus the printed number carry the same info. Critical for colour blindness.

## Ad strategy (AdMob)
- **No ads at all during a race** — not even a banner. Break focus and the player blames the ad.
- **Banner:** menu / level map / settings only.
- **Interstitial:** only when *leaving* a results screen; 1 per 3 races, 90 s minimum gap, **none in levels 1–5**.
- **Rewarded (optional):** "3 more balls" on defeat (once per race), 3rd star on victory.
- One-time "Remove ads" purchase in Settings.

## Porting to Godot
- Single colour source: `res://ui/theme/palette.gd` as `const`; derive the `.tres` theme from it.
- Buttons/cards: 9-slice **`StyleBoxTexture`**, not `StyleBoxFlat` — wood grain and cream paper can't be faked with a gradient.
- Theme needs all four states (normal/hover/pressed/disabled) for `Button`, `Label`, `Panel`, `PanelContainer`.
- `stretch/mode=canvas_items` is already correct; add `aspect=expand` so tablets get side padding instead of stretched art.
- Blinking bulbs: `AnimationPlayer` + `modulate`, not a shader — free on mobile GPUs.

## Motion spec
| Event | Duration / Easing |
|---|---|
| Ball throw arc | 350 ms · `TRANS_QUAD, EASE_OUT` |
| Hole hit | 120 ms · scale 1→1.22→1 + bulb flare + haptic |
| "+6" score popup | rises 24 px, fades over 600 ms |
| Horse advance | 600 ms · `EASE_OUT_BACK` |
| Screen shake | red hits only, 4 px / 100 ms |

Respect the system "reduce motion" setting: confetti and shake switch off.

## Next steps
1. Port palette + typography into a `.tres` Theme resource.
2. Update `ScoringBoard.tscn` colours — lowest effort, most visible win.
3. Produce 9-slice wood/cream texture assets (button, card, HUD frame).
4. Rebuild Main Menu and results screens on the new theme — can run in parallel with Phase 2 (gameplay loop).
