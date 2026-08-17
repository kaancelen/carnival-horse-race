# Carnival Horse Race — v1 Scaffold

Portrait-split carnival horse race arcade game. Godot 4.3, mobile (Android/iOS, tablets).

## What's in this scaffold

```
project.godot                  # portrait-locked, mobile renderer, autoloads registered
icon.svg
scenes/
  main/Main.tscn                # root: splits screen into Race (top) + ScoringBoard (bottom)
  race/Race.tscn                 # 5 horse lanes (placeholder panels, no art yet)
  ui/ScoringBoard.tscn           # 6 holes: 1 red / 2 yellow / 3 green, sized by tier
scripts/
  autoload/
    GameEvents.gd                # event bus — racer_scored(racer_id, points, hole_id) is canonical
    GameState.gd                 # scores, win target (24), difficulty-by-level
    AudioDirector.gd             # stub: hoofbeat tempo + crowd tension, wired to positions signal
  core/
    Horse.gd                     # plain logic class, no inspector wiring
    ScoringHole.gd                # hole tiers/points, default 6-hole layout
    RaceManager.gd                # owns Horses, listens to racer_scored, drives race_ended
  ai/
    AIController.gd              # difficulty profiles (easy/medium/hard), scores via GameEvents
```

## Architecture notes (why it's built this way)

- **Everything funnels through `GameEvents.racer_scored`.** AI, player throws, and any future
  networked opponent all call `GameEvents.report_score(racer_id, points, hole_id)`. RaceManager
  doesn't know or care who scored — this is what makes multiplayer a later add, not a rewrite.
- **Logic lives in plain GDScript classes** (`Horse`, `ScoringHole`, `RaceManager`), not baked into
  inspector-wired scene nodes. Everything's readable top-to-bottom in the script, which matters both
  for you and for iterating with AI assistance.
- **AI difficulty is data**, not branching code — `AIController.PROFILES` holds accuracy/timing/red-bias
  per difficulty. `GameState.difficulty_for_level()` maps level number → difficulty for progression.
- **Scoring symmetry is enforced by construction**: `ScoringHole.POINTS_BY_TIER` gives 1×6 = 2×3 = 3×2 = 6,
  so tune from one place if that ever changes.

## Third-party assets

- `assets/sprites/horses/*.png` — "Horse Pack" by loota9 (http://linktr.ee/loota9), licensed
  CC BY 4.0. Each file is a 64×48-cell animation sheet (idle/walk/run/rear/hit, side + front/back);
  `HorseMarker.gd` currently only slices the row-12 gallop cycle out of it.

## Not built yet (still placeholder/stub)

- Swipe-to-throw input + ball physics — nothing captures touch yet
- Hole *detection* (Area2D collision → `ball_landed`) — ScoringHole is data-only, no physical hookup
- AudioDirector TODOs (tempo/tension mapping) — signals are wired, no actual audio nodes/streams yet
- UI screens (menu, level select, results) — only Main/Race/ScoringBoard exist
- Firebase/AdMob plugin integration
- Real level data (currently just `GameState.difficulty_for_level` with hardcoded thresholds)

## Suggested next step

Phase 2 in the plan: **swipe-to-throw ball physics + hole collision**, since that's what turns this
from wiring into an actual playable loop — everything else (AI, scoring, audio) already reacts to
`GameEvents.ball_landed` / `racer_scored` once that exists.
