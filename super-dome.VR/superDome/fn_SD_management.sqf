// SUPER DOME v1.0
// File: your_mission\superDome\fn_SD_management.sqf
// Documentation: your_mission\superDome\_SD_Documentation.pdf
// by thy (@aldolammel)


// Only server can access:
if !isServer exitWith {};

[] spawn {

	// EDITOR'S OPTIONS ////////////////////////////////////////////////////////////////////////////////////////////////
	// Define where are your protect zones and stuff:
		
		SD_isOnSuperDome      = true;    // true = enable the script to run / false = it doesnt be loaded. Default: true.
		SD_isOnDebugGlobal    = true;   // true = a debug monitor visible / false = not visible. Default: false.
		SD_isOnAlerts         = true;    // true = player got text alerts when protected and not protected. Default: true.
		SD_isProtectedPlayer  = true;    // true = Protected zones protect all player of the same side / false = doesnt protect. Default: true.
		SD_isProtectedVehicle = true;    // true = Protected zones protect all vehicle inside / false = doesnt protect. Default: true.
		SD_isProtectedAI      = true;    // true = Protected zones protect all AI units inside / false = doesnt protect. Default: true.
		SD_checkDelay         = 3;       // in seconds, time before the next protection check. Default: 3.

		// PROTECTED ZONES
		// Define each protected zones you are running. Leave the _protectedMkrXX empty ("") to ignore a slot:

		private _protectedMkr01 = "superdome_1";      // Protected zone marker 1 name.
		private _mkrDisRange01  = 50;                 // in meters, the protection range of the marker 1.
		private _mkrSide01      = BLUFOR;              // Options: BLUFOR, OPFOR, INDEPENDENT, CIVILIAN.

		private _protectedMkr02 = "superdome_2";       // Protected zone marker 2 name.
		private _mkrDisRange02  = 50;                  // in meters, the protection range of the marker 2.
		private _mkrSide02      = BLUFOR;              // Options: BLUFOR, OPFOR, INDEPENDENT, CIVILIAN.

		private _protectedMkr03 = "";                  // Protected zone marker 3 name.
		private _mkrDisRange03  = 100;                 // in meters, the protection range of the marker 3.
		private _mkrSide03      = BLUFOR;              // Options: BLUFOR, OPFOR, INDEPENDENT, CIVILIAN.

		private _protectedMkr04 = "";                  // Protected zone marker 4 name.
		private _mkrDisRange04  = 100;                 // in meters, the protection range of the marker 4.
		private _mkrSide04      = BLUFOR;              // Options: BLUFOR, OPFOR, INDEPENDENT, CIVILIAN.

		private _protectedMkr05 = "";                  // Protected zone marker 5 name.
		private _mkrDisRange05  = 100;                 // in meters, the protection range of the marker 5.
		private _mkrSide05      = BLUFOR;              // Options: BLUFOR, OPFOR, INDEPENDENT, CIVILIAN.

		private _protectedMkr06 = "";                  // Protected zone marker 6 name.
		private _mkrDisRange06  = 100;                 // in meters, the protection range of the marker 6.
		private _mkrSide06      = BLUFOR;              // Options: BLUFOR, OPFOR, INDEPENDENT, CIVILIAN.

		private _protectedMkr07 = "";                  // Protected zone marker 7 name.
		private _mkrDisRange07  = 100;                 // in meters, the protection range of the marker 7.
		private _mkrSide07      = BLUFOR;              // Options: BLUFOR, OPFOR, INDEPENDENT, CIVILIAN.

		private _protectedMkr08 = "";                  // Protected zone marker 8 name.
		private _mkrDisRange08  = 100;                 // in meters, the protection range of the marker 8.
		private _mkrSide08      = BLUFOR;              // Options: BLUFOR, OPFOR, INDEPENDENT, CIVILIAN.

		private _protectedMkr09 = "";                  // Protected zone marker 9 name.
		private _mkrDisRange09  = 100;                 // in meters, the protection range of the marker 9.
		private _mkrSide09      = BLUFOR;              // Options: BLUFOR, OPFOR, INDEPENDENT, CIVILIAN.

		private _protectedMkr10 = "";                  // Protected zone marker 10 name.
		private _mkrDisRange10  = 100;                 // in meters, the protection range of the marker 10.
		private _mkrSide10      = BLUFOR;              // Options: BLUFOR, OPFOR, INDEPENDENT, CIVILIAN.
	

		// ADVANCED:
		// Which types of vehicles the SD should scan if SD_isProtectedVehicle is true:
		SD_scanVehTypes = ["Car", "Tank", "Plane", "Submarine", "Helicopter", "Motocycle", "Ship", "StaticWeapon"];



	// DONT TOUCH //////////////////////////////////////////////////////////////////////////////////////////////////////
	// Local variables declaration:
	private ["_protectedMkrs"];
	// Initial values:
	SD_protectedMkrsInfo    = [];
	SD_serverSideStatus = "Failed.";
	// Declarations:
	SD_debugHeader   = toUpper "SD DEBUG >";
	SD_warningHeader = toUpper "SD WARNING >";
	SD_alertHeader   = toUpper "SUPERDOME INFO >";
	SD_speedLimit    = 30;
	// Building the array structure for further steps:
	_protectedMkrs = [
		[_protectedMkr01, _mkrDisRange01, _mkrSide01, nil, nil],  // nil1 = [vehs classnames further], nil2 = [ai groups further]
		[_protectedMkr02, _mkrDisRange02, _mkrSide02, nil, nil],
		[_protectedMkr03, _mkrDisRange03, _mkrSide03, nil, nil],
		[_protectedMkr04, _mkrDisRange04, _mkrSide04, nil, nil],
		[_protectedMkr05, _mkrDisRange05, _mkrSide05, nil, nil],
		[_protectedMkr06, _mkrDisRange06, _mkrSide06, nil, nil],
		[_protectedMkr07, _mkrDisRange07, _mkrSide07, nil, nil],
		[_protectedMkr08, _mkrDisRange08, _mkrSide08, nil, nil],
		[_protectedMkr09, _mkrDisRange09, _mkrSide09, nil, nil],
		[_protectedMkr10, _mkrDisRange10, _mkrSide10, nil, nil]
	];
	// Cleaning the empty markers and those ones with irregular marker types:
	{  // forEach _protectedMkrs:
		// If marker's name is not empty:
		if ( (_x # 0) isNotEqualTo "" ) then { 
			// If marker has a valid shape type:
			if ( markerType (_x # 0) isNotEqualTo "" ) then {
				// If the protection range at least follows the minimal range:
				if ( (_x # 1) >= 50 ) then {
					// Check if the side is declared:
					if ( (_x # 2) isEqualTo BLUFOR || (_x # 2) isEqualTo OPFOR || (_x # 2) isEqualTo INDEPENDENT || (_x # 2) isEqualTo CIVILIAN ) then {
						// Adds the marker as a valid protected zone:
						SD_protectedMkrsInfo pushBack _x;
					// Otherwise:
					} else {
						// Warning message:
						systemChat format ["%1 '%2' protected zone has an INVALID SIDE. Use only BLUFOR, OPFOR, INDEPENDENT, or CIVILIAN. Fix it in 'fn_SD_management.sqf' file.",
						SD_warningHeader, toUpper (_x # 0)];
						// Change the marker name:
						(_x # 0) setMarkerText " ERROR: invalid side!";
					};
				// Otherwise:
				} else {
					// Warning message:
					systemChat format ["%1 '%2' protected zone has its protection RANGE LESS THAN 50m. Fix it in 'fn_SD_management.sqf' file.",
					SD_warningHeader, toUpper (_x # 0)];
					// Change the marker name:
					(_x # 0) setMarkerText " ERROR: low range!";
				};
			// Otherwise:
			} else {
				// Warning message:
				systemChat format ["%1 '%2' protected zone has an INVALID SHAPE TYPE. On Eden, use only marker types to set your protected zone positions.",
				SD_warningHeader, toUpper (_x # 0)];
			};
		};
	} forEach _protectedMkrs;
	// Configuring each valid protected zone:
	{  // forEach SD_protectedMkrsInfo:
		// Defining the name of each marker:
		(_x # 0) setMarkerText format [" Protected zone (%1)", _x # 0];
		// Defining the color of each marker:
		switch (_x # 2) do {
			case BLUFOR:      { (_x # 0) setMarkerColor "colorBLUFOR" };
			case OPFOR:       { (_x # 0) setMarkerColor "colorOPFOR" };
			case INDEPENDENT: { (_x # 0) setMarkerColor "colorIndependent" };
			case CIVILIAN:    { (_x # 0) setMarkerColor "colorCivilian" };
		};
	} forEach SD_protectedMkrsInfo;
	// Debug message:
	if SD_isOnDebugGlobal then { systemChat format ["%1 Using %2 valid protected zone(s).", SD_debugHeader, count SD_protectedMkrsInfo] };
	// Mission editor other warnings:
	if (SD_checkDelay < 2) then {systemChat format ["%1 When 'SD_checkDelay' is less than 2secs (current=%2) this may impact on server and client CPU performances.", SD_warningHeader, SD_checkDelay]}; if (SD_checkDelay > 5) then {systemChat format ["%1 When 'SD_checkDelay' is more than 5secs (current=%2) this may impact the reliability of the protection in some cases.", SD_warningHeader, SD_checkDelay]}; if ( SD_speedLimit isNotEqualTo 30 ) then {systemChat format ["%1 To change 'SD_speedLimit' value (default=30) can break the script logic easily. Be super careful!", SD_warningHeader]};
	// Declaring the global variables:
	publicVariable "SD_isOnSuperDome"; publicVariable "SD_isOnDebugGlobal"; publicVariable "SD_isOnAlerts"; publicVariable "SD_isProtectedPlayer"; publicVariable "SD_isProtectedVehicle"; publicVariable "SD_isProtectedAI"; publicVariable "SD_checkDelay"; publicVariable "SD_debugHeader"; publicVariable "SD_warningHeader"; publicVariable "SD_alertHeader"; publicVariable "SD_speedLimit"; publicVariable "SD_scanVehTypes"; publicVariable "SD_protectedMkrsInfo"; publicVariable "SD_serverSideStatus";
};
// return:
true;
