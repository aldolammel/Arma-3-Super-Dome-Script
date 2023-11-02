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

	params ["_mkrInfo", "_veh", "_crew"];
	private ["_timeout", "_mkr", "_mkrPos", "_rng", "_vehs"];

	// Escape:
		// Reserved space;
	// Initial values:
		// Reserved space;
	// If more than one veh is running this function, this waitUntil force the others to wait:
	waitUntil { sleep 5; !SD_isRemoving };
	// Remove it temporally of the valid vehs to check, and avoid a crazy looping for this vehicle in specific:
	(_mkrInfo # 3) deleteAt ((_mkrInfo # 3) find _veh);
	// Updating the global variable:
	publicVariable "SD_zonesCollection";
	// Declarations:
	_timeout      = time + SD_vehDelTolerance;
	_mkr          = _mkrInfo # 0;
	_mkrPos       = getMarkerPos _mkr;
	_rng          = _mkrInfo # 1;
	_vehs         = _mkrInfo # 3;
	SD_isRemoving = true;  // Flagging for other issued vehicles doenst require the auto-removal at the same time.
	publicVariable "SD_isRemoving";
	// Debug message:
	if SD_isOnDebugGlobal then { systemChat format ["%1 '%2' vehs-list updated: %3 veh(s)/static weapon(s).", SD_debugHeader, toUpper _mkr, count _vehs]; sleep 2};
	// Player message (Mandatory):
	[format ["%1 %2 secs to fix the vehicle position before its auto-removal.", SD_alertHeader, SD_vehDelTolerance]] remoteExec ["systemChat", _crew];
	// Waiting until the timeout runs, or veh pos be fixed, or veh explode, or be moved to out of zone:
	waitUntil { sleep 10; time > _timeout || (vectorUp _veh # 2) > SD_vehLeaning || !alive _veh || _veh distance _mkrPos > _rng };
	// If somehow the veh gets out of protected zone, restoring its regular condition:
	if ( _veh distance _mkrPos > _rng ) then { _veh allowDamage true } else { sleep 10 /* at zone, wait to see if the veh won't flip again */};
	// If veh still alive (Zeus can force a explosion or throw the veh out of zone), and restore to regular position:
	if ( alive _veh ) then {
		// If veh pos is fixed:
		if ( (vectorUp _veh # 2) > SD_vehLeaning ) then {
			// Restore the veh:
			_vehs pushBack _veh;
			// Update the global var:
			publicVariable "SD_zonesCollection";
			// Send the message to the crew members (Mandatory):
			[format ["%1 Auto-removal canceled.", SD_alertHeader]] remoteExec ["systemChat", _crew];
		// If veh still in a bad pos:
		} else {
			// Force the current crew (alive or unconscious) to leave the vehicle:
			{ moveOut _x } forEach crew _veh;  // "crew _veh" will check only the current units inside the veh. Don't use _crew here!
			// Animation breath:
			sleep 1;
			// Delete the veh:
			deleteVehicle _veh;
		};
	// If somehow the veh blew up:
	} else {
		// Delete the wreck, if inside the zone:
		if ( _veh distance _mkrPos > _rng ) then { deleteVehicle _veh };
	};
	// Debug message:
	if SD_isOnDebugGlobal then { systemChat format ["%1 '%2' vehs-list updated: %3 veh(s)/static weapon(s).", SD_debugHeader, toUpper _mkr, count (_mkrInfo # 3)] };
	// Flagging that the function has been finished:
	SD_isRemoving = false;
	publicVariable "SD_isRemoving";
	// Return:
	true;
};


THY_fnc_SD_debugMonitor = {
	// show info on screen for each player with debug is true.
	// Returns nothing.

	params ["_unit"];
	//private [];
	
	// Monitor:
	hintSilent format [
		"\n
		\n--- SUPER DOME DEBUG ---
		\n
		\nYou are: %1
		\nYour side: %2
		\nYou protected now: %3
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
	// Restart the function:
	[_unit] spawn THY_fnc_SD_debugMonitor;
	// Return:
	true;
};
// Return:
true;
