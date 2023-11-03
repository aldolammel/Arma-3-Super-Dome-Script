// SUPER DOME v1.2
// File: your_mission\superDome\fn_SD_globalFunctions.sqf
// Documentation: your_mission\superDome\_SD_Documentation.pdf
// by thy (@aldolammel)


/* THY_fnc_SD_xxxxxxxxxxxx = {
	// This function ...
	// Returns nothing.

	params ["", "", ""];
	private ["", "", ""];

	// Initial values:
		// Reserved space;
	// Declarations:
		// Reserved space;
	// Main function:
		// Reserved space;
	// Return:
	true;
}; */


THY_fnc_SD_vehicle_autoRemoval = {
	// This function is ............
	// Returns nothing.

	params ["_veh", "_rng", "_zonePos"];
	private ["_crew", "_tol", "_timeout"];

	// Take the current crew:
	_crew = crew _veh;
	// Wait to see if the veh not just rolled over once before return to a regular position:
	sleep 5;
	// Escape:
	if ( (vectorUp _veh # 2) >= SD_leanLimit ) exitWith {};
	// Initial values:
	_tol = 0;
	// Timeout calc - the time's cutted in a half if no crew:
	if (count _crew > 0) then { 
		_tol = SD_vehDelTolerance;
		// Player message (Mandatory):
		[format ["%1 %2 secs left to turn over the equipment before its auto-removal!", SD_alertHeader, _tol]] remoteExec ["systemChat", _crew];
	} else {
		_tol = (SD_vehDelTolerance / 2);
		// Debug message:
		if SD_isOnDebugGlobal then { systemChat format ["%1 ANTI-ROLLOVER > %2 secs left to auto-removal of '%3'.", SD_debugHeader, _tol, typeOf _veh] };
	};  
	// Declarations:
	_timeout = time + _tol;
	// Waiting until the timeout runs, or veh pos be fixed, or veh explode, or be moved to out of zone:
	waitUntil { sleep 10; time > _timeout || (vectorUp _veh # 2) >= SD_leanLimit || !alive _veh || _veh distance _zonePos > _rng };
	// If somehow the veh gets out of zone, restoring its regular condition:
	if ( _veh distance _zonePos > _rng ) then { _veh allowDamage true } else { sleep 5 /* at zone, wait to see if the veh won't roll over again */};
	// If veh still alive (Zeus can force a explosion or throw the veh out of zone), and restore to regular position:
	if ( alive _veh ) then {
		// If the regular veh pos is recovered:
		if ( (vectorUp _veh # 2) >= SD_leanLimit ) then {
			// Message to the crew (Mandatory):
			[format ["%1 Auto-removal canceled.", SD_alertHeader]] remoteExec ["systemChat", _crew];
		// If veh still in a bad pos:
		} else {
			// Force the current crew (alive or unconscious) to leave the vehicle:
			{ moveOut _x } forEach crew _veh;  // "crew _veh" will check only the current units inside the veh. Don't use _crew here!
			// Delete the veh:
			deleteVehicle _veh;
			// Debug message:
			if SD_isOnDebugGlobal then { format ["%1 ANTI-ROLLOVER > '%2' has been deleted.", SD_warningHeader, typeOf _veh] call BIS_fnc_error };
		};
	// If somehow the veh blew up:
	} else {
		// Message to the crew (Mandatory):
		[format ["%1 Auto-removal canceled.", SD_alertHeader]] remoteExec ["systemChat", _crew];
		// Delete the wreck, if inside the zone:
		if ( _veh distance _zonePos > _rng ) then { deleteVehicle _veh };
	};
	// Return:
	true;
};


THY_fnc_SD_protection_vehicle = {
	// This function ...
	// Returns nothing.

	params ["_veh", "_rng", "_zonePos"];
	//private ["", "", ""];

	// Escape:
		// Reserved space;
	// Initial values:
		// Reserved space;
	// Declarations:
		// Reserved space;
	// If veh still in-game:
	while { alive _veh } do {
		// if inside the protection range:
		if ( _veh distance _zonePos <= _rng ) then {
			// if inside the speed limit:
			if ( abs (speed _veh) <= SD_speedLimit ) then {
				// Makes vehicle unbreakable:
				if ( isDamageAllowed _veh ) then { _veh allowDamage false };
				// If veh pos is NOT ok:
				if ( (vectorUp _veh # 2) < SD_leanLimit ) then {
					[_veh, _rng, _zonePos] call THY_fnc_SD_vehicle_autoRemoval;
					// Escape:
					if ( !alive _veh ) exitWith {};
				};
			};
		// Otherwise:
		} else {
			// Restores veh condition:
			if ( !(isDamageAllowed _veh) ) then { _veh allowDamage true };
		};
		// CPU breath:
		sleep (1.5 * SD_checkDelay);
	};
	// Return:
	true;
};


THY_fnc_SD_protection_aiUnits = {
	// This function ...
	// Returns nothing.

	params ["_ai", "_mkr", "_rng", "_zonePos"];
	//private ["", "", ""];

	// Escape:
	if !SD_isProtectedAI exitWith {};
	// Initial values:
		// Reserved space;
	// Declarations:
		// Reserved space;
	// Main function:
	
					// If AI unit (_ai) is alive and inside the protected zone:
					if ( alive _ai && _ai distance _mkrPos <= _rng ) then {
						// Makes the unit immortal:
						_ai allowDamage false;
						//
					// Otherwise:
					} else {
						// Restores the unit condition:
						_ai allowDamage true;
					};
					// Breath:
					sleep 0.1;



	// Return:
	true;
};


THY_fnc_SD_debugMonitor = {
	// show info on screen for each player with debug is true.
	// Returns nothing.

	params ["_unit"];
	//private [];
	
	while { SD_isOnDebugGlobal } do {
		// Monitor:
		hintSilent format [
			"\n
			\n--- SUPER DOME DEBUG ---
			\n
			\nYou are: %1
			\nYour side: %2
			\nAre you protected: %3
			\n
			\n---
			\n
			\nPlayers protection: %4
			\nVehs protection: %5
			\nAI protection: %6
			\nSD player alerts: %7
			\nSD visible markers: %8
			\nSD stuff on Zeus: %9
			\n
			\n",
			name _unit,
			playerSide,
			if (isDamageAllowed _unit) then {"NOPE!"} else {"YES!"},
			if SD_isProtectedPlayer then {"ON"} else {"OFF"},
			if SD_isProtectedVehicle then {"ON"} else {"OFF"},
			if SD_isProtectedAI then {"ON"} else {"OFF"},
			if SD_isOnAlerts then {"ON"} else {"OFF"},
			if SD_isOnShowMarkers then {"ON"} else {"OFF"},
			if SD_isOnZeusWhenDebug then {"ON"} else {"OFF"}
		];
		// Breath:
		sleep 3;
	};
	// Return:
	true;
};
// Return:
true;
