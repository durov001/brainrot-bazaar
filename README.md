# BRAINROT BAZAAR

[![make.fun · roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/durov001/brainrot-bazaar/rank.svg)](https://make.fun/bounty/roblox-brainrot-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/durov001/brainrot-bazaar/reward.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)

Built for the make.fun roblox-brainrot-01 bounty: https://make.fun/bounty/roblox-brainrot-01 (referral: https://make.fun/r/zsk0hsg3)

Brainrot Bazaar is a 3D collector and base-builder in a floating Indonesian street-food market at golden hour. Buy original food characters, carry them home, place them on eight pedestals, earn income, rebirth for a multiplier, and shelter from monsoon waves while a thief patrols unlocked bases.

How to play:

- WASD moves your character.
- E buys the nearest market offer; F places a carried character on the next free pedestal.
- L locks your base for 60 seconds; R rebirths when you can pay the formula cost.
- P pauses and M mutes audio. Sell buttons in MY BASE return half of the listed price.

Modules:

- `BrainrotData` and `Config` are shared sources of truth.
- `World` builds the docks, stalls, bases, conveyor, lighthouse, lanterns, boats, and palms.
- `BrainrotModels` builds all twelve original characters from parts.
- `GameServer` validates economy requests and runs income, market, thief, and monsoon systems.
- `Thief` and `Monsoon` contain the hazard behavior.
- `Game.client` builds the title screen, HUD, labels, prompts, banners, and popups.

Build and package:

```sh
export PATH="$HOME/.local/bin:$PATH"
rojo build default.project.json --output game.rbxl
mkdir -p out
MAKEFUN_OUTPUT_DIR=out node main.ts
```
