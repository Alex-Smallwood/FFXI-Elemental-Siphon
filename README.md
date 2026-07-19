# Elemental Siphon

A simple Windower addon for Summoners that automatically manages Elemental Siphon.

When the Summoner’s MP reaches 30% or lower, the addon will:

1. Dismiss the currently summoned avatar or spirit, if one is active.
2. Summon the elemental spirit matching the current Vana’diel day.
3. Use Elemental Siphon.
4. Dismiss the elemental spirit after Elemental Siphon is used.
5. Wait until Elemental Siphon’s actual in-game cooldown has ended before attempting the sequence again.

The addon will not attempt the sequence inside supported town zones or a Mog House.

## Installation

Create the following folder inside your Windower addons directory:

```text
Windower4\addons\elemental_siphon\
```

Place the Lua file inside that folder:

```text
Windower4\addons\elemental_siphon\elemental_siphon.lua
```

## Load Command

Load the addon in-game with:

```text
//lua load elemental_siphon
```

You can also use the shorter command:

```text
//lua l elemental_siphon
```

## Manual Commands

The addon runs automatically when MP reaches 30% or lower.

To manually start the Elemental Siphon sequence, use:

```text
//es
```

The following commands also work:

```text
//es go
//es siphon
```

Manual use still respects:

* Elemental Siphon’s actual in-game cooldown
* The 30-second retry delay
* Town and Mog House restrictions

## Unload Command

Unload the addon with:

```text
//lua unload elemental_siphon
```

You can also use:

```text
//lua u elemental_siphon
```

## How It Works

The addon checks the Summoner’s MP approximately once per second.

When MP reaches 30% or lower, the addon checks:

* The player is alive.
* Summoner is the main job or support job.
* The player is not inside a blocked town or Mog House.
* The 30-second retry delay has ended.
* Elemental Siphon’s actual in-game recast is ready.

When all requirements are met, the addon selects the spirit associated with the current Vana’diel day:

* Firesday — Fire Spirit
* Earthsday — Earth Spirit
* Watersday — Water Spirit
* Windsday — Air Spirit
* Iceday — Ice Spirit
* Lightningday — Thunder Spirit
* Lightsday — Light Spirit
* Darksday — Dark Spirit

The addon then dismisses any currently summoned avatar or spirit, summons the correct elemental spirit, uses Elemental Siphon, and dismisses the spirit afterward.

## Supported Town Restrictions

Automatic and manual Elemental Siphon attempts are blocked in the following areas:

### San d’Oria

* Southern San d’Oria
* Northern San d’Oria
* Port San d’Oria

### Bastok

* Bastok Mines
* Bastok Markets
* Port Bastok
* Metalworks

### Windurst

* Windurst Waters
* Windurst Walls
* Port Windurst
* Windurst Woods
* Heavens Tower

### Jeuno

* Ru’Lude Gardens
* Upper Jeuno
* Lower Jeuno
* Port Jeuno

### Other Towns

* Selbina
* Mhaura
* Kazham
* Norg
* Rabao
* Nashmau
* Aht Urhgan Whitegate
* Tavnazian Safehold
* Western Adoulin
* Eastern Adoulin
* Chocobo Circuit
* Mog Garden

The addon also blocks all attempts while the player is inside a Mog House.

## Requirements

* Windower 4
* Summoner as the main job or support job
* The required elemental spirit spells
* Elemental Siphon unlocked at level 50

## Notes

* The automatic trigger activates when MP reaches 30% or lower.
* The addon checks Elemental Siphon’s actual in-game recast instead of relying on an internal five-minute timer.
* The addon does nothing while the player is inside a supported town or Mog House.
* After changing zones, the addon waits 30 seconds before making an automatic attempt.
* If an attempt fails outside a blocked town, the addon waits 30 seconds before trying again.
* The retry delay prevents repeated error-message spam.
* If MP remains at or below 30% after Elemental Siphon’s cooldown ends, the addon will run the sequence again when conditions allow.
* The timing between actions may need adjustment depending on connection latency and casting speed.
* The addon does not automate combat, movement, Blood Pacts, or other gameplay actions.

## Version History

### v1.5.0

#### New
- Added automatic release of the summoned elemental spirit after Elemental Siphon.
- Verified compatibility with Trust.

#### Fixed
- Fixed an issue where the summoned elemental spirit could remain active after Elemental Siphon.
- Removed unreliable action-packet detection that could prevent the release sequence from completing.
- Improved release handling by retrying the Release command until the spirit is dismissed or the retry limit is reached.

#### Improved
- Improved the overall timing and reliability of the Elemental Siphon sequence.

### v1.4.0

#### New
- Switched to Elemental Siphon's actual in-game recast.
- Added blocked town and Mog House detection.
- Added a 30-second retry delay after failed attempts.

#### Improved
- Improved automatic sequence reliability.

### v1.3.0

#### New
- Added automatic MP monitoring.
- Added manual commands (`//es`, `//es go`, `//es siphon`).

#### Improved
- Improved action timing.
