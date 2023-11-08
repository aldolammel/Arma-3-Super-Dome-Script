// SUPER DOME v1.5
// File: your_mission\superDome\fn_SD_serverSide.sqf
// Documentation: your_mission\superDome\_SD_Documentation.pdf
// by thy (@aldolammel)


if !isServer exitWith {};

[] spawn {
	// Escape:
	if ( !SD_isOnSuperDome || { !SD_isProtectedVehicle && !SD_isProtectedAI }) exitWith {};
	
	//params [""];
	private ["_mkr", "_rng", "_side", "_vehsByZone", "_aiUnitsByZone", "_zonePos", "_vehsFound", "_counter", "_tag", "_var", "_result", "_zonesAllSides", "_zonesBySide"];

	// Initial values:
	_mkr           = ""; 
	_rng           = 0;
	_side          = nil;
	_vehsByZone    = [];
	_aiUnitsByZone = [];
	_zonePos       = [];
	_vehsFound     = [];
	_counter       = 0;
	_tag           = "";
	_var           = "";
	_result        = [];
	_zonesAllSides = [[/* 0=blu */],[/* 1=opf */],[/* 2=ind */],[/* 3=civ */]];
	_zonesBySide   = [];
	// Declarations:
	SD_serverSideStatus = "ON";
	publicVariable "SD_serverSideStatus";
	// Debug message to everyone if client-side if OFF:
	if ( SD_isOnDebugGlobal && !SD_isProtectedPlayer ) then {
		[format ["%1 Server-side status: .. ON", SD_debugHeader]] remoteExec ["systemChat", 0];
		[format ["%1 Client-side status: .. %2", SD_debugHeader, SD_clientSideStatus]] remoteExec ["systemChat", 0];
	};
	// Wait for the match get started:
	waitUntil { sleep 0.5; time > SD_wait };


	// STEP 1 - SCAN
	// Check each protected zone:
	for "_i" from 0 to (count SD_zonesCollection) - 1 do {
		// Internal Declarations - part 1/2:
		_mkr     = (SD_zonesCollection # _i) # 0;
		_rng     = (SD_zonesCollection # _i) # 1;
		_side    = (SD_zonesCollection # _i) # 2;
		_zonePos = getMarkerPos _mkr;
		/*
			HASHMAP:
			SD_zonesCollection = [
				0= [ 0= marker1 classname, 1= range integer, 2= side it belongs, 3= [ veh1, ... ], 4= [ aiUnit1, ... ] ],
				1= [ 0= marker2 classname, 1= range integer, 2= side it belongs, 3= [ veh1, ... ], 4= [ aiUnit1, ... ] ],
				...,
				9= [ ... ]
			];
		*/
		// SCAN > EQUIPMENTS:
		if SD_isProtectedVehicle then {
			// Seaching for equipments in the zone range:
			_vehsFound = nearestObjects [_zonePos, SD_scanVehTypes, _rng];
			// if something was found:
			if ( count _vehsFound > 0 ) then {
				// To number each varName:
				_counter = 0;
				// Validing each equipment will be found now:
				{  // forEach _vehsFound:
					// If no varName (not chosen by Editor or automatic set by Arma Respawn Vehicle Module):
					if ( vehicleVarName _x isEqualTo "") then {  // "bis_oX_XXXX" is a varname set by Arma Respawn Vehicle Module when vehicle is synced to the module on Eden.
						// Defining tag:
						switch _side do {
							case BLUFOR:      { _tag = "blu" };
							case OPFOR:       { _tag = "opf" };
							case INDEPENDENT: { _tag = "ind" };
							case CIVILIAN:    { _tag = "civ" };
						};
						// Unique number:
						_counter = _counter + 1;
						// Building the varName as: _var = noRespawnTag_ + sideTag + zoneIndex + equipmentNumber (example: norspwn_blu_z0_eq1).
						_var = "norspwn_" + _tag + "_z" + (str _i) + "_eq" + (str _counter);
						// Applying the varName built:
						_x setVehicleVarName _var;
						// Telling to Arma 3 Respawn Vehicle Module that this varName must be preserved after respawn if it happens:
						_x call BIS_fnc_objectVar;  // https://community.bistudio.com/wiki/BIS_fnc_objectVar
					};
					// Adding each equipment found to the list:
					_result pushBack _x;
				} forEach _vehsFound;
				// Recording them:
				(SD_zonesCollection # _i) set [3, _result];
				// Adding to Zeus when debugging:
				if ( SD_isOnDebugGlobal && SD_isOnZeusWhenDebug ) then { { _x addCuratorEditableObjects [_result, true]; sleep 0.1 } forEach allCurators };
				// CPU breath:
				sleep 0.25;
			};
		};

		// SCAN > AI UNITS:
		if SD_isProtectedAI then {
			// Looking for:
			_result = ((_zonePos nearEntities ["Man", _rng]) - allPlayers) select { alive _x && _x isKindOf "CAManBase" && side _x isEqualTo _side };
			// if something was found:
			if ( count _result > 0 ) then {
				// Recording them:
				(SD_zonesCollection # _i) set [4, _result];
				// Adding to Zeus when debugging:
				if ( SD_isOnDebugGlobal && SD_isOnZeusWhenDebug ) then { { _x addCuratorEditableObjects [_result, true]; sleep 0.1 } forEach allCurators };
				// CPU breath:
				sleep 0.25;
			};
		};


		// SCAN > ZONES COLLECTION BY SIDE:
		// Internal Declarations - part2/2:
		_vehsByZone    = (SD_zonesCollection # _i) # 3;
		_aiUnitsByZone = (SD_zonesCollection # _i) # 4;
		// Check which side is here, and drop the zone information in the correct side-index:
		switch _side do {
			case BLUFOR:      { (_zonesAllSides # 0) pushBack [_mkr, _rng, _zonePos, _vehsByZone, _aiUnitsByZone] };
			case OPFOR:       { (_zonesAllSides # 1) pushBack [_mkr, _rng, _zonePos, _vehsByZone, _aiUnitsByZone] };
			case INDEPENDENT: { (_zonesAllSides # 2) pushBack [_mkr, _rng, _zonePos, _vehsByZone, _aiUnitsByZone] };
			case CIVILIAN:    { (_zonesAllSides # 3) pushBack [_mkr, _rng, _zonePos, _vehsByZone, _aiUnitsByZone] };
			/*
				HASHMAP:
				_zonesAllSides = [
					0=[ blu
						0=[ zone
							0=_mkr,
							1=_rng,
							2=_zonePos,
							3=[veh1, veh2, ...],
							4=[ai1, ai2, ...]
						],
						1=[ zone
							0=_mkr,
							1=_rng,
							2=_zonePos,
							3=[veh1, veh2, ...],
							4=[ai1, ai2, ...]
						],
						...
					],
					1=[ opf
						...
					],
					2=[ ind
						...
					],
					3=[ civ
						...
					]
				];
			*/
		};
		// Debug:
		if SD_isOnDebugGlobal then {
			// Message:
			systemChat format ["%1 %2 '%3' zone has %4 equipment(s) and %5 AI(s) protected.",
			SD_debugHeader, str _side, toUpper _mkr, if (count _vehsByZone > 0) then {count _vehsByZone} else {0}, if (count _aiUnitsByZone > 0) then {count _aiUnitsByZone} else {0}];
			// Message breath:
			sleep 3;
		};
		// Clean variables to the next usage:
		_vehsByZone    = [];
		_aiUnitsByZone = [];
		// Additional CPU breath:
		sleep 1;
	};  // For-loop ends.
	// Updating the global variable:
	publicVariable "SD_zonesCollection";

	// STEP 2 - GIVING PROTECTION:
	// Check each side based on _zonesAllSides HASHMAP:
	for "_i" from 0 to 3 do {
		systemChat str _i;
		// Internal declarations - part 1/3:
		_zonesBySide = _zonesAllSides # _i;
		// Escape if index content's empty:
		if ( count _zonesBySide isEqualTo 0 ) then { continue };
		{  // forEach _zonesBySide:
			// If protection for equipments available:
			if SD_isProtectedVehicle then {
				// WIP - what if this forEach below is empty?
				// Internal declarations - part 2/3:
				_vehsByZone = _x # 3;
				systemChat str _vehsByZone;
				// Starts a new thread for each equipment of a specific side (like vehicle and static weapon that must be protected):
				{ [_zonesBySide, _x] spawn THY_fnc_SD_protection_equipment; sleep 0.1 } forEach _vehsByZone;  // each = obj
			};
			// If protection for AI available:
			if SD_isProtectedAI then {
				// WIP - what if this forEach below is empty?
				// Internal declarations - part 3/3:
				_aiUnitsByZone = _x # 4;
				// Starts a new thread for each AI must be protected:
				{ [_zonesBySide, _x] spawn THY_fnc_SD_protection_aiUnit; sleep 0.1 } forEach _aiUnitsByZone;  // each = obj
			};

		} forEach _zonesBySide;
		// CPU breath:
		sleep SD_checkDelay;
	};  // For-loop ends.
};	// Spawn ends.
// Return:
true;
