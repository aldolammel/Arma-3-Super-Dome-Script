// SUPER DOME v1.0
// File: your_mission\superDome\fn_SD_clientSide.sqf
// Documentation: your_mission\superDome\_SD_Documentation.pdf
// by thy (@aldolammel)


// Only players (incl. player host) can access:
if ( !hasInterface || !SD_isOnSuperDome || !SD_isProtectedPlayer ) exitWith {};

[] spawn {

	//params [""];
	private ["_mkr", "_rng", "_booking", "_protectedMkrs"];

	// Initial values:
	_mkr           = objNull;
	_rng           = nil; 
	_booking       = [""];
	_protectedMkrs = [];
	// Declarations:
		// Reserved space:
	// Debug message:
	if SD_isOnDebugGlobal then {
		systemChat format ["%1 ServerSide status... %2", SD_debugHeader, SD_serverSideStatus];
		systemChat format ["%1 ClientSide status... (%2) Running!", SD_debugHeader, name player];
	};
	{  // forEach SD_protectedMkrsInfo:
		// Checks if should hide the protected-markers:
		if !SD_isOnDebugGlobal then { (_x # 0) setMarkerAlpha 0 } else { (_x # 0) setMarkerAlpha 1 };
		// If marker is from the same player's side, consider the marker as valid protected zone:
		if ( (_x # 2) isEqualTo playerSide ) then { _protectedMkrs pushBack _x };
	} forEach SD_protectedMkrsInfo;
	// Wait for the player be alive on the map:
	waitUntil { sleep 1; !isNull player };
	// Debug:
	if SD_isOnDebugGlobal then {
		// Shows the SD monitor:
		[player] spawn THY_fnc_SD_debugMonitor;
	};
	// Looping to check the protected zones:
	while { SD_isOnSuperDome } do {
		// If player alive:
		if ( alive player ) then {
			{  // forEach _protectedMkrs:
				// Declarations:
				_mkr = _x # 0;
				_rng = _x # 1;
				//private _side = _x # 2;
				// If this base-marker is NOT already booked:
				if ( (_booking # 0) isNotEqualTo _mkr ) then {
					// if player is into the base range, respecting the speed limit:
					if ( player distance (getMarkerPos _mkr) <= _rng && abs (speed player) < SD_speedLimit ) then {
						// Makes player immortal:
						player allowDamage false;
						// It does the booking:
						_booking = [_mkr];
						// Message:
						if ( SD_isOnDebugGlobal || SD_isOnAlerts ) then { systemChat format ["%1 You're in a protected zone (%2).", if SD_isOnAlerts then {SD_alertHeader} else {SD_debugHeader}, _mkr]; sleep 1 };
					};
				// If this base-marker is already booked:
				} else {
					// if player is out of the current booked base range:
					if ( (_booking # 0) isNotEqualTo "" && player distance (getMarkerPos _mkr) > _rng ) then {
						// Restores the player mortality:
						player allowDamage true;
						// Undo the booking:
						_booking = [""];
						// Message:
						if ( SD_isOnDebugGlobal || SD_isOnAlerts ) then { systemChat format ["%1 You left the protected zone (%2).", if SD_isOnAlerts then {SD_alertHeader} else {SD_debugHeader}, _mkr]; sleep 1 };
					};
				};
				// Breath:
				sleep 0.2;
			} forEach _protectedMkrs;
		// If player is dead:
		} else {
			// Redundancy to make sure no immortal bugs:
			_booking = [""];
		};
		// CPU breath:
		sleep SD_checkDelay;
	}; // while-looping ends.
};	// Spawn ends.
// Return:
true;
