# Changelog

## 12.1.0

- Catch % uses extra decimals under 1% (0.1%, 0.08%) instead of rounding rare fish to 0%

## 1.6.6

- Export format toggle: Discord (```) or Wowhead ([code]) so columns stay aligned on both
- Removed the Copy button (WoW cannot write the clipboard; use Ctrl+C)

## 1.6.5

- Export is a padded, readable dump (code-block wrapped for Discord)
- Gold shown as 900g 9s instead of 900.09
- Zone line includes a paste-ready waypoint: `Zone: Orgrimmar | /way #1454 61.79, 38.60`

## 1.6.4

- Export button in expanded view (under Reset). Copies a tab-separated session you can paste into Discord or a spreadsheet. `/fk export`
- Click Catch, Qty, %, or Value in expanded mode to sort. Click the same header again to reverse.
- Fish ID list covers Classic through Midnight, plus fishing junk, clams, treasure bags, and coins
- Announce still hides unknown fish by name (trout, perch, trophies, new patches)

## 1.6.3

First public release.

- Compact fishing bar and expanded catch list
- TSM prices: Region avg or Min buyout (vendor fallback, grey always vendor)
- Session timer starts on the first cast; pause, start, and confirmed reset
- Patient Treasure chest loot is tracked and tagged
- The Coiled Huntress venom (equipped only)
- Midnight Angler's Grand Line on/off
- Announce catches replaces default fishing loot chat
- Themes: Steel, Gold, Night, Horde, Alliance, Simple
