// SUPER DOME v1.5
// File: your_mission\superDome\fn_SD_management.sqf
// Documentation: your_mission\superDome\_SD_Documentation.pdf
// by thy (@aldolammel)


// Only server can access:
if !isServer exitWith {};

[] spawn {

	// EDITOR'S OPTIONS ////////////////////////////////////////////////////////////////////////////////////////////////
	// Define where are your protected zones and stuff:
		
		SD_isOnSuperDome          = true;    // true = enable the script to run / false = it doesnt be loaded. Default: true.
			// Debugging:
			SD_isOnDebugGlobal    = true;   // true = make your tests easier / false = turn it off. Default: false.
			SD_isOnZeusWhenDebug  = true;   // true = when debugging only, all protected things will be added to zeus. Default: false.
			// Protections:
			SD_isProtectedPlayer  = true;    // true = zones protect all player of the same side / false = doesnt protect. Default: true.
			SD_isProtectedVehicle = true;    // true = zones protect all vehicle and static weapons that spawn inside / false = doesnt protect. Default: true.
			SD_isProtectedAI      = true;   // true = zones protect all AI units inside / false = doesnt protect. Default: false.
			// Customs:
			SD_isOnShowMarkers    = true;    // true = Show the zones only for players of the same side / false = hide them. Default: true.
			SD_isOnAlerts         = true;    // true = player got text alerts when protected and not protected. Default: true.

		// PROTECTED ZONES
		// Define each protected zones you are running. Leave the _protectedMkrXX empty ("") to ignore the slot:

			private _protectedMkr01 = "superdome_1";      // Protected zone marker 1 name.
			private _mkrDisRange01  = 50;                 // in meters, the protection range of the marker 1. Minimum 50.
			private _mkrSide01      = BLUFOR;             // Options: BLUFOR, OPFOR, INDEPENDENT, CIVILIAN.

			private _protectedMkr02 = "superdome_2";      // Protected zone marker 2 name.
			private _mkrDisRange02  = 50;                 // in meters, the protection range of the marker 2. Minimum 50.
			private _mkrSide02      = BLUFOR;             // Options: BLUFOR, OPFOR, INDEPENDENT, CIVILIAN.

			private _protectedMkr03 = "superdome_3";      // Protected zone marker 3 name.
			private _mkrDisRange03  = 50;                 // in meters, the protection range of the marker 3. Minimum 50.
			private _mkrSide03      = OPFOR;              // Options: BLUFOR, OPFOR, INDEPENDENT, CIVILIAN.

			private _protectedMkr04 = "";                 // Protected zone marker 4 name.
			private _mkrDisRange04  = 100;                // in meters, the protection range of the marker 4. Minimum 50.
			private _mkrSide04      = BLUFOR;             // Options: BLUFOR, OPFOR, INDEPENDENT, CIVILIAN.

			private _protectedMkr05 = "";                 // Protected zone marker 5 name.
			private _mkrDisRange05  = 100;                // in meters, the protection range of the marker 5. Minimum 50.
			private _mkrSide05      = BLUFOR;             // Options: BLUFOR, OPFOR, INDEPENDENT, CIVILIAN.

			private _protectedMkr06 = "";                 // Protected zone marker 6 name.
			private _mkrDisRange06  = 100;                // in meters, the protection range of the marker 6. Minimum 50.
			private _mkrSide06      = BLUFOR;             // Options: BLUFOR, OPFOR, INDEPENDENT, CIVILIAN.

			private _protectedMkr07 = "";                 // Protected zone marker 7 name.
			private _mkrDisRange07  = 100;                // in meters, the protection range of the marker 7. Minimum 50.
			private _mkrSide07      = BLUFOR;             // Options: BLUFOR, OPFOR, INDEPENDENT, CIVILIAN.

			private _protectedMkr08 = "";                 // Protected zone marker 8 name.
			private _mkrDisRange08  = 100;                // in meters, the protection range of the marker 8. Minimum 50.
			private _mkrSide08      = BLUFOR;             // Options: BLUFOR, OPFOR, INDEPENDENT, CIVILIAN.

			private _protectedMkr09 = "";                 // Protected zone marker 9 name.
			private _mkrDisRange09  = 100;                // in meters, the protection range of the marker 9. Minimum 50.
			private _mkrSide09      = BLUFOR;             // Options: BLUFOR, OPFOR, INDEPENDENT, CIVILIAN.

			private _protectedMkr10 = "";                 // Protected zone marker 10 name.
			private _mkrDisRange10  = 100;                // in meters, the protection range of the marker 10. Minimum 50.
			private _mkrSide10      = BLUFOR;             // Options: BLUFOR, OPFOR, INDEPENDENT, CIVILIAN.
	

		// ADVANCED:
		// Be careful even more here:

			// In seconds, time before the next protection check for players, vehicles/static weapons, and AI units:
			SD_checkDelay = 3;  // Default 3.
			// Do protected vehicles and/or static weapons have respawn hability?
			SD_isAcceptingRespawn = false;  // Default: false.
			// In seconds, how much time players got to fix vehicle position before it been deleted when it get upside-down in a protected zone:
			SD_vehDelTolerance = 30;  // Default 30.
			// Which types of vehicles the SD should scan if SD_isProtectedVehicle is true:
			SD_scanVehTypes = ["Car", "Tank", "Helicopter", "Motocycle", "Plane", "StaticWeapon", "Ship", "Submarine"];
			// In seconds, how much time the script must wait before to go into its functions right after the mission gets started:
			SD_wait = 1;  // Default 1;


	// DONT TOUCH //////////////////////////////////////////////////////////////////////////////////////////////////////
	// Local variables declaration:
	private ["_zones", "_mkr", "_rng", "_side"];
	// Declarations - part 1/2:
	SD_debugHeader = toUpper "SD DEBUG >";
	// Declaring the global variables - part 1/2:
	publicVariable "SD_isOnSuperDome"; publicVariable "SD_isOnDebugGlobal"; publicVariable "SD_isOnZeusWhenDebug"; publicVariable "SD_isProtectedPlayer"; publicVariable "SD_isProtectedVehicle"; publicVariable "SD_isProtectedAI"; publicVariable "SD_isOnShowMarkers"; publicVariable "SD_isOnAlerts"; publicVariable "SD_debugHeader";
	// Escape:
	if ( !SD_isOnSuperDome || { !SD_isProtectedPlayer && !SD_isProtectedVehicle && !SD_isProtectedAI } ) exitWith { if SD_isOnDebugGlobal then { systemChat format ["%1 Super-Dome was shut down by the mission editor!", SD_debugHeader] } };
	// Initial values:
	SD_zonesCollection  = [];
	SD_serverSideStatus = "OFF";
	SD_clientSideStatus = "OFF";
	_mkr                = "";
	_rng                = 0;
	_side               = nil;
	// Declarations - part 2/2:
	SD_warnHeader  = toUpper "SD WARNING >";
	SD_alertHeader = toUpper "SUPERDOME INFO >";
	SD_speedLimit  = 30;
	SD_leanLimit   = 0.5;
	// Building the array structure for further steps:
	_zones = [
		[_protectedMkr01, _mkrDisRange01, _mkrSide01, [], []],  // 3= [vehicles], 4= [ai units];
		[_protectedMkr02, _mkrDisRange02, _mkrSide02, [], []],
		[_protectedMkr03, _mkrDisRange03, _mkrSide03, [], []],
		[_protectedMkr04, _mkrDisRange04, _mkrSide04, [], []],
		[_protectedMkr05, _mkrDisRange05, _mkrSide05, [], []],
		[_protectedMkr06, _mkrDisRange06, _mkrSide06, [], []],
		[_protectedMkr07, _mkrDisRange07, _mkrSide07, [], []],
		[_protectedMkr08, _mkrDisRange08, _mkrSide08, [], []],
		[_protectedMkr09, _mkrDisRange09, _mkrSide09, [], []],
		[_protectedMkr10, _mkrDisRange10, _mkrSide10, [], []]
	];
	// Cleaning the empty markers and those ones with irregular marker types:
	{  // forEach _zones:
		// Intrnal declarations:
		_mkr  = _x # 0;
		_rng  = _x # 1;
		_side = _x # 2;
		// If marker's name is not empty:
		if ( _mkr isNotEqualTo "" ) then { 
			// If marker has a valid shape type:
			if ( markerType _mkr isNotEqualTo "" ) then {
				{  // forEach SD_zonesCollection:
					// Check if the marker is not duplicated 'cause the editor declared 2 or more times the same marker:
					if ( _mkr isEqualTo (_x # 0) ) then {
						// Warning message:
						systemChat format ["%1 '%2' marker is been used TWO OR MORE TIMES. Fix it in 'fn_SD_management.sqf' file.", SD_warnHeader, toUpper _mkr];
						// Delete the current marker:
						_zones deleteAt (_zones find _mkr);
					};
				} forEach SD_zonesCollection;
				// If the protection range at least follows the minimal range:
				if ( _rng >= 50 ) then {
					// Check if the side is declared:
					if ( _side in [BLUFOR, OPFOR, INDEPENDENT, CIVILIAN] ) then {
						// Adds the marker as a valid protected zone:
						SD_zonesCollection pushBack _x;
					// Otherwise:
					} else {
						// Warning message:
						systemChat format ["%1 '%2' protected zone has an INVALID SIDE. Use only BLUFOR, OPFOR, INDEPENDENT, or CIVILIAN. Fix it in 'fn_SD_management.sqf' file.",
						SD_warnHeader, toUpper _mkr];
						// Change the marker name:
						_mkr setMarkerText " ERROR: invalid side declaration!";
					};
				// Otherwise:
				} else {
					// Warning message:
					systemChat format ["%1 '%2' protected zone has its protection RANGE LESS THAN 50m. Fix it in 'fn_SD_management.sqf' file.",
					SD_warnHeader, toUpper _mkr];
					// Change the marker name:
					_mkr setMarkerText " ERROR: low range!";
				};
			// Otherwise:
			} else {
				// Warning message:
				systemChat format ["%1 '%2' protected zone DOESN'T EXIST or has an INVALID SHAPE TYPE. On Eden, use only marker types to set your protected zone positions.",
				SD_warnHeader, toUpper _mkr];
			};
		};
	} forEach _zones;
	// Error handling:
	if ( count SD_zonesCollection isEqualTo 0 ) exitWith {
		// Warning message:
		systemChat format ["%1 NO PROTECTED ZONE WAS FOUND! SD script was shut down to preserve the server CPU. Make sure you declare all your protect zone marker names in 'fn_SD_management.sqf' file.", SD_warnHeader];
		// Update the script switch:
		SD_isOnSuperDome = false;
		publicVariable "SD_isOnSuperDome";
	};
	// Configuring each valid protected zone:
	{  // forEach SD_zonesCollection:
		// Intrnal declarations:
		_mkr  = _x # 0;
		_side = _x # 2;
		// Setting the mkr name:
		_mkr setMarkerText format [" Protected zone %1", if SD_isOnDebugGlobal then {"(" + _mkr + ")"} else {""}];
		// Setting the mkr color:
		switch _side do {
			case BLUFOR:      { _mkr setMarkerColor "colorBLUFOR" };
			case OPFOR:       { _mkr setMarkerColor "colorOPFOR" };
			case INDEPENDENT: { _mkr setMarkerColor "colorIndependent" };
			case CIVILIAN:    { _mkr setMarkerColor "colorCivilian" };
		};
		// Force to show marker position already in pre-game screen (briefing, example) when in debug-mode:
		if SD_isOnDebugGlobal then { _mkr setMarkerAlpha 1 } else { _mkr setMarkerAlpha 0 };
	} forEach SD_zonesCollection;
	// Debug message:
	if SD_isOnDebugGlobal then { systemChat format ["%1 Found %2 valid protected zone(s).", SD_debugHeader, count SD_zonesCollection] };
	// Mission editor other warnings:
	if ( SD_checkDelay < 2 ) then { systemChat format ["%1 When 'SD_checkDelay' is less than 2secs (current=%2) this may impact on server and client CPU performances.", SD_warnHeader, SD_checkDelay] }; if ( SD_checkDelay > 5 ) then { systemChat format ["%1 When 'SD_checkDelay' is more than 5secs (current=%2) this may impact the reliability of the protection in some cases.", SD_warnHeader, SD_checkDelay] }; if ( SD_speedLimit isNotEqualTo 30 ) then { systemChat format ["%1 To change 'SD_speedLimit' value (default=30) can break the script logic easily. Be super careful!", SD_warnHeader] };
	// Errors handling:
	if ( SD_wait < 1 ) then { SD_wait = 1; if SD_isOnDebugGlobal then { systemChat format ["%1 fn_SD_management.sqf > 'SD_wait' value CANNOT be less than 1. The value was fixed to the minimum.", SD_debugHeader] } }; if ( SD_vehDelTolerance < 10 ) then { SD_vehDelTolerance = 10; if SD_isOnDebugGlobal then { systemChat format ["%1 fn_SD_management.sqf > 'SD_vehDelTolerance' value CANNOT be less than 10. The value was fixed to the minimum.", SD_debugHeader] } };	if ( count SD_scanVehTypes isEqualTo 0 ) then { SD_scanVehTypes = ["Car", "Tank", "Helicopter", "Motocycle"]; if SD_isOnDebugGlobal then { systemChat format ["%1 fn_SD_management.sqf > 'SD_scanVehTypes' looks empty. The basic vehicle types was set again.", SD_debugHeader] } };
	// Declaring the global variables - part 2/2:
	publicVariable "SD_warnHeader"; publicVariable "SD_alertHeader"; publicVariable "SD_speedLimit"; publicVariable "SD_leanLimit"; publicVariable "SD_zonesCollection"; publicVariable "SD_serverSideStatus"; publicVariable "SD_clientSideStatus"; publicVariable "SD_checkDelay"; publicVariable "SD_isAcceptingRespawn"; publicVariable "SD_vehDelTolerance"; publicVariable "SD_scanVehTypes"; publicVariable "SD_wait";
};
// return:
true;
