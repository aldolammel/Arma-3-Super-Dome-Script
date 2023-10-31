// SUPER DOME v1.0
// File: your_mission\superDome\fn_SD_serverSide.sqf
// Documentation: your_mission\superDome\_SD_Documentation.pdf
// by thy (@aldolammel)


// Escapes:
if ( !isServer || !SD_isOnSuperDome || { !SD_isProtectedVehicle && !SD_isProtectedAI } ) exitWith {};

[] spawn {

	//params [""];
	private ["_result", "_mkr", "_rng", "_side", "_vehs", "_aiUnits"];

	// Initial values:
	_mkr     = ""; 
	_rng     = 0;
	_side    = nil;
	_vehs    = [];
	_aiUnits = [];
	_result  = [];
	// Declarations - part 1/2:
	SD_serverSideStatus = "Running!";
	publicVariable "SD_serverSideStatus";
	// Wait for the match get started:
	waitUntil { sleep 1; time > 1 };
	// SCAN > CONTENT GUIDELINE:
	/* 
		SD_protectedMkrsInfo = [
			0=[ 0= marker1 classname to protect, 1= range integer to protect, 2= player's side to protect, 3= [ veh objs to protect, ..., ... ], 4= [ ai groups to protect, ..., ...] ],
			1=[ 0= marker2 classname to protect, 1= range integer to protect, 2= player's side to protect, 3= [ veh objs to protect, ..., ... ], 4= [ ai groups to protect, ..., ...] ],
			2=[ ... ]
			...
		];
	*/
	// STEP 1 - SCAN > SEARCHING FOR VEHICLES AND AI UNITS:
	{  // forEach SD_protectedMkrsInfo:
		// Declarations - part 2/2:
		_mkr  = _x # 0;
		_rng  = _x # 1;
		_side = _x # 2;
		// Scan to collect vehicles:
		if SD_isProtectedVehicle then {
			// Looking for vehicles:
			_result = nearestObjects [getMarkerPos _mkr, SD_scanVehTypes, _rng];
			// Recording them:
			_x set [3, _result];  // if empty, at least change the array index-value from nil to array (empty).
			// CPU breath:
			sleep 0.5;
		// Otherwise:
		} else {
			// Change index-value from nil to array (empty):
			_x set [3, []];
		};
		// Scan to collect AI units:
		if SD_isProtectedAI then {
			// Looking for AI units:
			_result = ((getMarkerPos _mkr) nearEntities ["Man", _rng]) select { alive _x && _x isKindOf "CAManBase" && side _x isEqualTo _side };
			// Recording them:
			_x set [4, _result];  // if empty, at least change the array index-value from nil to array (empty).
			// CPU breath:
			sleep 0.5;
		// Otherwise:
		} else {
			// Change index-value from nil to array (empty):
			_x set [4, []];
		};
		// Debug:
		if SD_isOnDebugGlobal then {
			// Message:
			systemChat format ["%1 %2 '%3' marker has %4 vehs and %5 AI groups protected.",
			SD_debugHeader, str _side, toUpper _mkr, if (count (_x # 3) > 0) then {count (_x # 3)} else {0}, if (count (_x # 4) > 0) then {count (_x # 4)} else {0}];
			// Message breath:
			sleep 3;
		};
		// Additional CPU breath:
		sleep 1;

	} forEach SD_protectedMkrsInfo;
	// Updating the global variable:
	publicVariable "SD_protectedMkrsInfo";

	// STEP 2 - PROTECT THEM:
	// Looping to check vehicles/Ai units:
	while { SD_isOnSuperDome } do {
		{  // forEach SD_protectedMkrsInfo:
			// Declarations:
			_mkr     = _x # 0;
			_rng     = _x # 1;
			//_side    = _x # 2;
			_vehs    = _x # 3;
			_aiUnits = _x # 4;
			// Should protect vehicles:
			if SD_isProtectedVehicle then {
				{  // forEach _vehs:
					// If vehicle (_x) is alive and inside the protected zone:
					if ( alive _x && _x distance (getMarkerPos _mkr) <= _rng && abs (speed _x) < SD_speedLimit ) then {
						// Makes vehicle unbreakable:
						_x allowDamage false;
					// Otherwise:
					} else {
						// Restores vehicle condition:
						_x allowDamage true;
						// Delete the wreck if it's destroyed:
						if ( !alive _x && _x distance (getMarkerPos _mkr) <= _rng ) then { deleteVehicle _x };
					};
					// Breath:
					sleep 0.1;
				} forEach _vehs;
			};
			// Should protect AI units:
			if SD_isProtectedAI then {
				{  // forEach _aiUnits:
					// If AI unit (_x) is alive and inside the protected zone:
					if ( alive _x && _x distance (getMarkerPos _mkr) <= _rng ) then {
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
		} forEach SD_protectedMkrsInfo;
		// CPU breath:
		sleep (1.5 * SD_checkDelay);
	}; // while-looping ends.
};	// Spawn ends.
// Return:
true;
