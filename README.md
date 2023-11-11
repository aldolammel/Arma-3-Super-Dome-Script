# Arma 3 / SD: Super Dome v1.5.1
>*Dependencies: none.*

SD is an Arma 3 script that's a smart protection against damage for players, vehicles, and AI units when they are within pre-defined zones. The protected zones have automatic removal of wrecks and rolled-over vehicles, in addition to small automation relating to the protected zone's integrity. Super-Dome script works both at the server layer and on each player's machine, allowing the editor to turn resources ON and OFF.

Creation concept: turn specific game zones into safe places for players, areas proof against their enemies and themselves.

## HOW TO INSTALL / DOCUMENTATION

video demo: soon.

Documentation: https://github.com/aldolammel/Arma-3-Super-Dome-Script/blob/main/_SD_Script_Documentation.pdf

__

## SCRIPT DETAILS

- No dependencies from mods or other scripts;
- SD works with two layers: player protection is managed by client-side, meanwhile vehicles and AI units by server-side;
- No need to set variables on Eden or anywhere else;
- Set up to 10 protected zones easily with drag-and-drop Eden markers;
- Turn ON/OFF the protected zones to cover all vehicles and static-weapons (turrets) inside;
- Turn ON/OFF the protected zones to cover all AI units inside;
- Turn ON/OFF the protected zones to cover all players by side;
- NEW! - Support to Eden Vehicle Respawn Module;
- Auto-removal for wrecks and rolled over vehicles in the zone;
- Smart speed limit (to disable the protection and accept hard collisions) and wreck delete when inside the zone;
- Debugging: friendly feedback messages;
- Debugging: automatic errors handling;
- Full documentation available.

__

## IDEA AND FIX?

Discussion and known issues: https://forums.bohemia.net/forums/topic/244082-release-sd-super-dome-script-protecting-bases-and-zones/

__

## CHANGELOG

**Nov, 11th 2023 | v1.5.1**
- Hotfix > When Eden Vehicle Respawn module is configured with lot of vehicles, and SD delete automatically the respawned vehicle wrecks, the module got lost;
- Documentation has been updated.

**Nov, 10th 2023 | v1.5**
- Added > Support to missions with respawn-points for players, vehicles and static weapons (turrets);
- Added > New layer of protection called "Additional Protection" (turn ON/OFF) where the server checks separately unknown stuck vehicles or its wrecks, and remove them;
- Fixed > Massive QA tests performed, addressing a few bugs already fixed;
- Fixed > Non-protected vehicles, when destroyed inside the protected zone, their wrecks weren't deleted;
- Improved > Protected vehicles, even when empty, must respect the speed limit (horizontal and vertical) inside the protected zone to maintain their protection;
- Improved > Players under the water with no diving gears, won't be immortal even in protected zones;
- Improved > Better support to Zeus module;
- Improved > Important debug improvements;
- Documentation has been updated.

**Nov, 5th 2023 | v1.2.1**
- Fixed > When a vehicle rolled over 2 or more times inside the protected zone, the anti-rollover system stoped working properly.
- Improved > Optimazed the way the script checks each protected thing;
- Documentation has been updated.

**Nov, 3rd 2023 | v1.2**
- Added > When protected vehicle (unbreakable) rolls over within the protected zone, it will be deleted after a countdown if the vehicle doesn't return a functional position;
- Added > When vehicle and player approach the protected zone too fast, the protection for them is disabled;
- Improved > Option to turn ON/OFF the markers of protected zones and its action ranges on the map;
- Fixed > AI protection was conflicting with Player protection when the player went to another protected zone from the same side;
- Improved > Debugging > bunch of small improvements;
- Improved > Debugging > Protected units, vehicles and turrets are editable by Zeus when debug is ON;
- Documentation has been updated.

**Oct, 31st 2023 | v1.0**
- Hello world.
