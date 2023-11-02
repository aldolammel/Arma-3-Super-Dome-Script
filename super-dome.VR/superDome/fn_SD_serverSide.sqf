// SUPER DOME v1.2
// File: your_mission\superDome\fn_SD_serverSide.sqf
// Documentation: your_mission\superDome\_SD_Documentation.pdf
// by thy (@aldolammel)


if !isServer exitWith {};

[] spawn {
	// Escape:
	if ( !SD_isOnSuperDome || { !SD_isProtectedVehicle && !SD_isProtectedAI }) exitWith {};
	
	//params [""];
	private ["_mkrInfo", "_mkr", "_rng", "_side", "_vehs", "_aiUnits", "_result", "_mkrPos", "_crew", "_zonesNum"];

	// Initial values:
	_mkrInfo  = [];
	_mkr      = ""; 
	_rng      = 0;
	_side     = nil;
	_vehs     = [];
	_aiUnits  = [];
	_result   = [];
	_mkrPos   = [];
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
	waitUntil { sleep 1; time > 1 };

	// SCAN > CONTENT GUIDELINE:
	/*
		SD_zonesCollection = [
			0= [ 0= marker1 classname to protect, 1= range integer to protect, 2= player's side to protect, 3= [ veh objs to protect, ..., ... ], 4= [ ai groups to protect, ..., ...] ],
			1= [ 0= marker2 classname to protect, 1= range integer to protect, 2= player's side to protect, 3= [ veh objs to protect, ..., ... ], 4= [ ai groups to protect, ..., ...] ],
			...,
			9= [ ... ]
		];
	*/

	// STEP 1 - SCAN > SEARCHING FOR VEHICLES AND AI UNITS:
	// Check each protected zone:
	for "_i" from 0 to _zonesNum do {
		// Internal Declarations:
		_mkrInfo = SD_zonesCollection # _i;
		_mkr     = _mkrInfo # 0;
		_rng     = _mkrInfo # 1;
		_side    = _mkrInfo # 2;
		_mkrPos  = getMarkerPos _mkr;
		// Scan to collect vehicles:
		if SD_isProtectedVehicle then {
			// Looking for vehicles:
			_result = nearestObjects [_mkrPos, SD_scanVehTypes, _rng];
			// Recording them:
			_mkrInfo set [3, _result];  // if empty, at least change the array index-value from nil to array (empty).
			// Adding to Zeus when debugging:
			if ( SD_isOnDebugGlobal && SD_isOnZeusWhenDebug ) then { { _x addCuratorEditableObjects [_result, true]; sleep 0.1 } forEach allCurators };
			// CPU breath:
			sleep 0.5;
		// Otherwise:
		} else {
			// Change index-value from nil to array (empty):
			_mkrInfo set [3, []];
		};
		// Scan to collect AI units:
		if SD_isProtectedAI then {
			// Looking for AI units:
			_result = (_mkrPos nearEntities ["Man", _rng]) select { alive _x && _x isKindOf "CAManBase" && side _x isEqualTo _side };
			// Recording them:
			_mkrInfo set [4, _result];  // if empty, at least change the array index-value from nil to array (empty).
			// Adding to Zeus when debugging:
			if ( SD_isOnDebugGlobal && SD_isOnZeusWhenDebug ) then { { _x addCuratorEditableObjects [_result, true]; sleep 0.1 } forEach allCurators };
			// CPU breath:
			sleep 0.5;
		// Otherwise:
		} else {
			// Change index-value from nil to array (empty):
			_mkrInfo set [4, []];
		};
		// Debug:
		if SD_isOnDebugGlobal then {
			// Message:
			systemChat format ["%1 %2 '%3' marker has %4 veh(s)/staticWeapon(s) and %5 AI unit(s) protected.",
			SD_debugHeader, str _side, toUpper _mkr, if (count (_mkrInfo # 3) > 0) then {count (_mkrInfo # 3)} else {0}, if (count (_mkrInfo # 4) > 0) then {count (_mkrInfo # 4)} else {0}];
			// Message breath:
			sleep 3;
		};
		// Additional CPU breath:
		sleep 1;
	};
	// Updating the global variable:
	publicVariable "SD_zonesCollection";

	// STEP 2 - PROTECT THEM:
	while { SD_isProtectedVehicle || SD_isProtectedAI } do {
		// Check each protected zone:
		for "_i" from 0 to _zonesNum do {
			// Internal Declarations:
			_mkrInfo = SD_zonesCollection # _i;
			_mkr     = _mkrInfo # 0;
			_rng     = _mkrInfo # 1;
			//_side    = _mkrInfo # 2;
			_vehs    = _mkrInfo # 3;
			_aiUnits = _mkrInfo # 4;
			_mkrPos  = getMarkerPos _mkr;
			// Should protect vehicles:
			if SD_isProtectedVehicle then {
				{  // forEach _vehs:
					// If veh still in-game:
					if ( alive _x ) then {
						// if inside the protection range:
						if ( _x distance _mkrPos <= _rng ) then {
							// if inside the speed limit:
							if ( abs (speed _x) < SD_speedLimit ) then {
								// Makes vehicle unbreakable:
								_x allowDamage false;
								// If veh position is NOT okay:
								if ( (vectorUp _x # 2) <= SD_vehLeaning ) then {
									// Take the current crew:
									_crew = crew _x;
									// Don't stop this looping check, but open another branch to auto-removal if really need:
									[_mkrInfo, _x, _crew] spawn THY_fnc_SD_vehicle_autoRemoval;
									// This only make sure at least one vehicle is already out of the veh-list to protect (avoiding check the same veh in another branch/spawn-command above):
									waitUntil { sleep 1; SD_isRemoving };
								};
							};
						// Otherwise:
						} else {
							// Restores veh condition:
							_x allowDamage true;
						};
					// Vehicle destroyed:
					} else {
						// Delete the wreck if it's in zone:
						if ( _x distance _mkrPos <= _rng ) then { deleteVehicle _x };
						// Remove it permanently of the valid vehs to check:
						_vehs deleteAt (_vehs find _x);
						// Updating the global variable:
						publicVariable "SD_zonesCollection";
						// Debug message:
						if SD_isOnDebugGlobal then { systemChat format ["%1 '%2' vehs-list after perma-delete: %3 veh(s).", SD_debugHeader, toUpper _mkr, count _vehs]; sleep 2};
					};
					// Breath:
					sleep 0.1;
				} forEach _vehs;
			};
			// Should protect AI units:
			if SD_isProtectedAI then {
				{  // forEach _aiUnits:
					// If AI unit (_x) is alive and inside the protected zone:
					if ( alive _x && _x distance _mkrPos <= _rng ) then {
						// Makes the unit immortal:
						_x allowDamage false;
					// Otherwise:
					} else {
						// Restores the unit condition:
						_x allowDamage true;
					};
					// Breath:
					sleep 0.1;
				} forEach _aiUnits;
			};
		};
		// CPU breath:
		sleep (1.5 * SD_checkDelay);
	}; // while-looping ends.
};	// Spawn ends.
// Return:
true;
