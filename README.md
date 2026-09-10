# FishKeeper

Retail World of Warcraft fishing tracker. Counts every catch, lists what you hooked, and prices the haul with TradeSkillMaster.

**Game:** Retail (Midnight, interface 120100 / 120105)  
**Optional:** [TradeSkillMaster](https://www.tradeskillmaster.com/) for auction values  
**Author:** frostaphim

## Install

1. Close World of Warcraft.
2. Copy the `FishKeeper` folder into `World of Warcraft/_retail_/Interface/AddOns/`.
3. Restart WoW and enable **FishKeeper** at the character select addon list.
4. Install TradeSkillMaster if you want AH prices. Without TSM, vendor sell is used.

The folder name must be `FishKeeper` (next to the `.toc` file).

## Window

Starts as a compact bar: catch count, timer, gold, last fish, venom.

- **+ / −** compact while fishing, expand for the list
- **[Pause] / [Start]** freeze or resume the session timer (loot still counts). The timer starts on your first cast, not on reset
- **[Reset]** asks for confirmation
- Hover the gold total for gold/hour and catches/hour
- **Grand Line: ON/OFF** and **Venom** from The Coiled Huntress (only while that pole is equipped)
- **[Region] / [Min BO]** toggles TSM `dbregionmarketavg` and `dbminbuyout`
- Six themes: Steel, Gold, Night, Horde, Alliance, Simple
- Drag to move. Shift-click a row to link the item

Patient Treasure chests are counted and tagged `[chest]`.

With **Announce catches** on, FishKeeper prints the catch and hides default loot chat while fishing. Loot from anything else still shows normally.

## Commands

| Command | Action |
| --- | --- |
| `/fk` | Toggle window |
| `/fk compact` | Compact / expanded |
| `/fk pause` | Pause / resume the session timer |
| `/fk price` | Toggle Region / Min BO |
| `/fk price region` | TSM dbregionmarketavg |
| `/fk price min` | TSM dbminbuyout |
| `/fk session` | Reset this session |
| `/fk reset confirm` | Wipe lifetime stats for this character |
| `/fk lock` | Lock/unlock the window |
| `/fk theme` | Cycle window theme |
| `/fk help` | Print help |

## Release (GitHub → CurseForge)

Repo root is this addon folder. A push to `main` zips the addon and uploads it.

1. Create the GitHub repo (example: `Gasteren/FishKeeper`).
2. Create the CurseForge WoW addon project and put its numeric id in `.github/workflows/release.yml` as `project_id`.
3. Add repo secret `FISHKEEPER` (CurseForge API token).
4. Push `main`, or run the workflow by hand.
