// SUPER DOME v1.5
// File: your_mission\superDome\fn_SD_serverSide.sqf
// Documentation: your_mission\superDome\_SD_Documentation.pdf
// by thy (@aldolammel)


if !isServer exitWith {};

[] spawn {
	// Escape:
	if ( !SD_isOnSuperDome || { !SD_isProtectedVehicle && !SD_isProtectedAI }) exitWith {};
	
	//params [""];
	private ["_mkr", "_rng", "_side", "_objTypesByZone", "_vehsByZone", "_aiUnitsByZone", "_zonePos", "_tag", "_result", "_allProtectedVehs", "_dangerEqpnts", "_zonesAllSides", "_zonesBySide"];

	// Initial values:
	_mkr              = ""; 
	_rng              = 0;
	_side             = nil;
	_objTypesByZone   = [];  // debug purposes.
	_vehsByZone       = [];
	_aiUnitsByZone    = [];
	_zonePos          = [];
	_tag              = "";
	_result           = [];
	_allProtectedVehs = [];
	_dangerEqpnts     = [];
	_zonesAllSides    = [[/* 0=blu */],[/* 1=opf */],[/* 2=ind */],[/* 3=civ */]];
	_zonesBySide      = [];
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
			_result = nearestObjects [_zonePos, SD_scanVehTypes, _rng];
			// if something was found:
			if ( count _result > 0 ) then {
				// Recording them:
				(SD_zonesCollection # _i) set [3, _result];
				//
				{ _allProtectedVehs pushBack _x } forEach _result;
				// Adding to Zeus when debugging:
				if ( SD_isOnDebugGlobal && SD_isOnZeusWhenDebug ) then { { _x addCuratorEditableObjects [_result, true]; sleep 0.1 } forEach allCurators };
				// Clean to not duplicate stuff:
				_result = [];
			};
			// CPU breath:
			sleep 0.1;
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
				// Clean to not duplicate stuff:
				_result = [];
			};
			// CPU breath:
			sleep 0.1;
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
			systemChat format ["%1 %2 > '%3' zone has %4 equipment(s) and %5 AI(s) protected.",
			SD_debugHeader, str _side, toUpper _mkr, if (count _vehsByZone > 0) then {count _vehsByZone} else {0}, if (count _aiUnitsByZone > 0) then {count _aiUnitsByZone} else {0}];
			// Message breath:
			sleep 3;
		};
		// Additional CPU breath:
		sleep 1;
	};  // For-loop ends.
	// Updating global variables:
	publicVariable "SD_zonesCollection";

	// STEP 2 - GIVING PROTECTION:
	// Check each side based on _zonesAllSides HASHMAP:
	for "_i" from 0 to 3 do {
		// Debug purposes:
		if SD_isOnDebugGlobal then {
			switch _i do {
				case 0: { _tag = "WEST" };
				case 1: { _tag = "EAST" };
				case 2: { _tag = "RESI" };
				case 3: { _tag = "CIVI" };
			};
		};
		// Internal declarations - part 1/3:
		_zonesBySide = _zonesAllSides # _i;
		// Escape if index content's empty:
		if ( count _zonesBySide isEqualTo 0 ) then { continue };
		{  // forEach _zonesBySide:
			// If protection for equipments available:
			if SD_isProtectedVehicle then {
				// Internal declarations - part 2/3:
				_vehsByZone = _x # 3;
				// Debug server message:
				if ( SD_isOnDebugGlobal && SD_isDebugDeeper ) then {
					// Make objs more readable:
					{ _objTypesByZone pushBack (typeOf _x) } forEach _vehsByZone;
					// Message:
					systemChat format ["%1 %2 > Z%3 > EQPNTS:", SD_debugHeader, _tag, (_zonesBySide find _x)+1];
					systemChat format ["%1.", if (count _vehsByZone > 0) then {str _objTypesByZone} else {"No equipment was found"}];
					// Clean variable:
					_objTypesByZone = [];
					// Breath:
					sleep 3;
				};
				// Starts a new thread for each equipment of a specific side (like vehicle and static weapon that must be protected):
				{ [_zonesBySide, _x] spawn THY_fnc_SD_protection_equipment; sleep 0.1 } forEach _vehsByZone;  // each = obj
			};
			// If protection for AI available:
			if SD_isProtectedAI then {
				// Internal declarations - part 3/3:
				_aiUnitsByZone = _x # 4;
				// Debug server message:
				if ( SD_isOnDebugGlobal && SD_isDebugDeeper ) then {
					// Make objs more readable:
					{ _objTypesByZone pushBack (typeOf _x) } forEach _aiUnitsByZone;
					// Message:
					systemChat format ["%1 %2 > Z%3 > AIs:", SD_debugHeader, _tag, (_zonesBySide find _x)+1];
					systemChat format ["%1.", if (count _aiUnitsByZone > 0) then {str _objTypesByZone} else {"No AI unit was found"}];
					// Clean variable:
					_objTypesByZone = [];
					// Breath:
					sleep 3;
				};
				// Starts a new thread for each AI must be protected:
				{ [_zonesBySide, _x] spawn THY_fnc_SD_protection_aiUnit; sleep 0.1 } forEach _aiUnitsByZone;  // each = obj
			};
		} forEach _zonesBySide;
		// CPU breath:
		sleep 1;
	};  // For-loop ends.
	// Additional protection:
	while { SD_isOnAdditionalProtection } do {
		// Repeat for the same amount of zones available:
		for "_i" from 0 to (count SD_zonesCollection) - 1 do {
			// Internal Declarations:
			_mkr     = (SD_zonesCollection # _i) # 0;
			_rng     = (SD_zonesCollection # _i) # 1;
			_zonePos = getMarkerPos _mkr;
			// Search for unknown equipments that are rollovered (P.S: known vehicles are verify separately in their own threads with countdown):
			_dangerEqpnts = (entities [["LandVehicle", "Air", "Ship"], []]) select {
				// those in the zone:
				_x distance2D _zonePos <= _rng &&
				// those still alive:
				alive _x &&
				// WIP : those apparently unknown (dropped by Zeus or just random veh from the mission) (Critical: without this, veh just respawned will be weirdly added in this checking):
				vehicleVarName _x isEqualTo "" &&
				// those aren't watched by Super-Dome:
				!(_x in _allProtectedVehs) &&
				// those apparently rollovered:
				(vectorUp _x # 2) < SD_leanLimit 
			};
			// Destroy them:
			if ( count _dangerEqpnts > 0 ) then { { _x setDamage [1, false]; sleep SD_checkDelay } forEach _dangerEqpnts };
			//
			{  // Delete all potential wrecks:
				// Debug server message:
				if SD_isOnDebugGlobal then {
					format ["%1 ANTI-WRECK > '%2' was deleted!",
					SD_debugHeader, typeOf _x] call BIS_fnc_error;
				};
				// Delete the thing:
				deleteVehicle _x;
				// Breath:
				sleep SD_checkDelay;
			} forEach (allDead select { _x distance2D _zonePos <= _rng && !(_x isKindOf "Man") && !(_x isKindOf "House") });
			// Internal breath:
			sleep SD_checkDelay;
		};  // for-loop ends.
		// External breath:
		sleep SD_AdditionalProtectTimer;
	};
};	// Spawn ends.
// Return:
true;
