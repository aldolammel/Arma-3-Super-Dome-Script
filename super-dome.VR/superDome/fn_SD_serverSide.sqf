// SUPER DOME v1.2
// File: your_mission\superDome\fn_SD_serverSide.sqf
// Documentation: your_mission\superDome\_SD_Documentation.pdf
// by thy (@aldolammel)


if !isServer exitWith {};

[] spawn {
	// Escape:
	if ( !SD_isOnSuperDome || { !SD_isProtectedVehicle && !SD_isProtectedAI }) exitWith {};
	
	//params [""];
	private ["_zoneInfo", "_mkr", "_rng", "_side", "_vehs", "_aiUnits", "_zonePos", "_result", "_crew", "_zonesNum"];

	// Initial values:
	_zoneInfo = [];
	_mkr      = ""; 
	_rng      = 0;
	_side     = nil;
	_vehs     = [];
	_aiUnits  = [];
	_zonePos  = [];
	_result   = [];
	_crew     = [];
	// Declarations:
	SD_serverSideStatus = "ON";
	publicVariable "SD_serverSideStatus";
	_zonesNum = count SD_zonesCollection - 1;
	// Debug message to everyone if client-side if OFF:
	if ( SD_isOnDebugGlobal && !SD_isProtectedPlayer ) then {
		[format ["%1 Server-side status: .. ON", SD_debugHeader]] remoteExec ["systemChat", 0];
		[format ["%1 Client-side status: .. %2", SD_debugHeader, SD_clientSideStatus]] remoteExec ["systemChat", 0];
	};
	// Wait for the match get started:
	waitUntil { sleep 0.5; time > SD_wait };

	// SCAN > CONTENT GUIDELINE:
	/*
		SD_zonesCollection = [
			0= [ 0= marker1 classname to protect, 1= range integer to protect, 2= player's side to protect, 3= [ veh objs to protect, ..., ... ], 4= [ ai groups to protect, ..., ...] ],
			1= [ 0= marker2 classname to protect, 1= range integer to protect, 2= player's side to protect, 3= [ veh objs to protect, ..., ... ], 4= [ ai groups to protect, ..., ...] ],
			...,
			9= [ ... ]
		];
	*/

	// STEP 1 - SCAN
	// Check each protected zone:
	for "_i" from 0 to _zonesNum do {
		// Internal Declarations - part 1/2:
		_zoneInfo = SD_zonesCollection # _i;
		_mkr     = _zoneInfo # 0;
		_rng     = _zoneInfo # 1;
		_side    = _zoneInfo # 2;
		_zonePos = getMarkerPos _mkr;
		
		// SCAN > VEHICLES & STATIC WEAPONS:
		if SD_isProtectedVehicle then {
			// Looking for vehicles and static turrets:
			_result = nearestObjects [_zonePos, SD_scanVehTypes, _rng];
			// Recording them:
			_zoneInfo set [3, _result];  // if empty, at least change the array index-value from nil to array (empty).
			// Adding to Zeus when debugging:
			if ( SD_isOnDebugGlobal && SD_isOnZeusWhenDebug ) then { { _x addCuratorEditableObjects [_result, true]; sleep 0.1 } forEach allCurators };
			// CPU breath:
			sleep 0.5;
		// Otherwise:
		} else {
			// Change index-value from nil to array (empty):
			_zoneInfo set [3, []];
		};

		// SCAN > AI UNITS:
		if SD_isProtectedAI then {
			// Looking for AI units:
			_result = ((_zonePos nearEntities ["Man", _rng]) - allPlayers) select { alive _x && _x isKindOf "CAManBase" && side _x isEqualTo _side };
			// Recording them:
			_zoneInfo set [4, _result];  // if empty, at least change the array index-value from nil to array (empty).
			// Adding to Zeus when debugging:
			if ( SD_isOnDebugGlobal && SD_isOnZeusWhenDebug ) then { { _x addCuratorEditableObjects [_result, true]; sleep 0.1 } forEach allCurators };
			// CPU breath:
			sleep 0.5;
		// Otherwise:
		} else {
			// Change index-value from nil to array (empty):
			_zoneInfo set [4, []];
		};

		// Internal Declarations - part2/2:
		_vehs    = _zoneInfo # 3;
		_aiUnits = _zoneInfo # 4;
		// Debug:
		if SD_isOnDebugGlobal then {
			// Message:
			systemChat format ["%1 %2 '%3' zone has %4 veh(s)/staticWeapon(s) and %5 AI unit(s) protected.",
			SD_debugHeader, str _side, toUpper _mkr, if (count _vehs > 0) then {count _vehs} else {0}, if (count _aiUnits > 0) then {count _aiUnits} else {0}];
			// Message breath:
			sleep 3;
		};
		// Additional CPU breath:
		sleep 1;
	};
	// Updating the global variable:
	publicVariable "SD_zonesCollection";

	// STEP 2 - GIVING PROTECTION:
	// Check each zone:
	for "_i" from 0 to _zonesNum do {
		// Internal declarations:
		_zoneInfo = SD_zonesCollection # _i;
		_mkr      = _zoneInfo # 0;
		_rng      = _zoneInfo # 1;
		_zonePos  = getMarkerPos _mkr;
		// If protection for equipments is available:
		if SD_isProtectedVehicle then {
			// Internal declarations:
			_vehs = _zoneInfo # 3;
			// Start a new thread for each vehicle must be protected:
			{ [_x, _rng, _zonePos] spawn THY_fnc_SD_protection_vehicle; sleep 0.1 } forEach _vehs;
		};
		// If protection for AI is available:
		if SD_isProtectedAI then {
			// Internal declarations:
			//_side    = _zoneInfo # 2;
			_aiUnits = _zoneInfo # 4;
			// Start a new thread for each AI must be protected:
			{ [_x, _rng, _zonePos] spawn THY_fnc_SD_protection_aiUnits; sleep 0.1 } forEach _aiUnits;
		};
		// CPU breath:
		sleep 1;
	};
};	// Spawn ends.
// Return:
true;
