# Arma 3 / SD: Super Dome v1.5
>*Dependencies: none.*

SD is an Arma 3 script that's a smart protection against damage for players, vehicles and AI units when them are within editable zones. The protected zones have automatic removal of wrecks and overturned vehicles, in addition to small automations relating to the protected zones integrity. Super-Dome script works both at the server layer and on each player's machine, allowing the editor to turn resources ON and OFF.

Creation concept: turn specific game zones into safe places for players, areas proof against their enemies and themselves.

## HOW TO INSTALL / DOCUMENTATION

video demo: soon.

Documentation: https://github.com/aldolammel/Arma-3-Super-Dome-Script/blob/main/super-dome.VR/superDome/_SD_Script_Documentation.pdf

__

## SCRIPT DETAILS

- No dependencies from other mods or scripts;
- SD works with two layers: player protection is managed by client-side, meanwhile vehicles and AI units by server-side; 
- Set up to 10 protected zones easily with drag-and-drop Eden markers;
- Turn ON/OFF the protected zones to cover all vehicles and static-turrets inside;
- Turn ON/OFF the protected zones to cover all AI units inside;
- Turn ON/OFF the protected zones to cover all players by side;
- Auto-removal for wrecks and rolled over vehicles in the zone;
- Smart speed limit (to desactivate the protection and accept hard collisions) and wreck delete when inside the zone;
- Debugging: friendly feedback messages;
- Debugging: automatic errors handling;
- Full documentation available.

__

## IDEA AND FIX?

Discussion and known issues: https://forums.bohemia.net/forums/topic/244082-release-sd-super-dome-script-protecting-bases-and-zones/

__

## CHANGELOG

**Nov, XXth 2023 | v1.5**
- Added > Support to missions with respawn-points;
- Added > xxxxxxxxxxxxxxxxxxxxxxxx;
- Fixed > xxxxxxxxxxxxxxxxxxxxxxxx;
- Fixed > xxxxxxxxxxxxxxxxxxxxxxxx;
- Improved > Protected vehicles, even when empty, must respect the speed limit inside the protected zone to maintain their protection;
- Improved > xxxxxxxxxxxxxxxxxxxxxxxx;
- Improved > Small debug improvements;
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
