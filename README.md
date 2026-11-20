# BRAINROT BAZAAR

[![make.fun · roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/durov001/brainrot-bazaar/rank.svg)](https://make.fun/bounty/roblox-brainrot-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/durov001/brainrot-bazaar/reward.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)

An entry for the [roblox-brainrot-01 bounty on make.fun](https://make.fun/bounty/roblox-brainrot-01) — a 3D collector and base-builder set in a floating Indonesian street-food market at golden hour. [Join make.fun with my referral link](https://make.fun/r/zsk0hsg3).

## The game

Twelve original food brainrots roam the stalls of a wooden market on teal water: from the Bakso Bandit (Common, $50) to the Klepon King (Divine, $500,000). Buy one, carry it home, place it on one of your eight pedestals, and watch cash tick up every second. Mutations (GOLD x2, DIAMOND x3, PEDAS x5) multiply income; rebirth resets your base for a permanent +25% multiplier per rebirth. A thief patrols unlocked bases, and every few minutes a monsoon wave sweeps the map — shelter under your roof or by the lighthouse.

## How to play

- WASD to walk around the market.
- E buys the nearest market offer (four offers rotate every 20 seconds).
- F places the brainrot you carry on your next free pedestal.
- L locks your base for 60 seconds (30 second recharge).
- R rebirths when you can afford it.
- P pauses, M mutes. SELL buttons in the MY BASE panel refund half the price.

## Modules

- `src/shared/Config.luau` — every tunable number, base and stall layout, remote names.
- `src/shared/BrainrotData.luau` — the twelve characters, rarities, mutations, economy formulas.
- `src/shared/PartKit.luau` — shared part and label builders for the server modules.
- `src/shared/UiKit.luau` — shared GUI builders for the client.
- `src/server/World.luau` — water, docks, stalls, bases, conveyor, lighthouse, lanterns, boats, palms.
- `src/server/BrainrotModels.luau` — the twelve character models, three with hero silhouettes.
- `src/server/Thief.luau` — the shadow thief that raids unlocked bases.
- `src/server/Monsoon.luau` — storm warnings and the sweeping wave.
- `src/server/GameServer.server.luau` — state, market, income, rebirth, locks, loops.
- `src/client/Game.client.luau` — title screen, HUD, base panel, missions, prompts, banners.
- `main.ts` — packages game.rbxl, src/, screenshots/ and PLAY.json and writes the dossier.

## Build

```sh
export PATH="$HOME/.local/bin:$PATH"
rojo build default.project.json --output game.rbxl
MAKEFUN_OUTPUT_DIR=out node main.ts
```

Play it on Roblox: https://www.roblox.com/games/117027210688795/Brainrot-Bazaar
