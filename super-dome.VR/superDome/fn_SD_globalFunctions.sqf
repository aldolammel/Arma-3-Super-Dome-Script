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


THY_fnc_SD_equipment_autoRemoval = {
	// This function will notify the crewmen, if there vehicle rollover at protected zone, it'll be deleted after a countdown.
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
		[format ["%1 %2 secs left to turn over the equipment before its auto-removal!", SD_warnHeader, _tol]] remoteExec ["systemChat", _crew];
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
			// If there's crew:
			if (count _crew > 0) then {
				// Message to the crew (Mandatory):
				[format ["%1 Auto-removal canceled.", SD_alertHeader]] remoteExec ["systemChat", _crew];
			} else {
				// Debug message:
				if SD_isOnDebugGlobal then { systemChat format ["%1 ANTI-ROLLOVER > Auto-removal canceled to '%2'.", SD_debugHeader, typeOf _veh] };
			};
		// If veh still in a bad pos:
		} else {
			// Force the current crew (alive or unconscious) to leave the vehicle:
			{ moveOut _x } forEach crew _veh;  // "crew _veh" will check only the current units inside the veh. Don't use _crew here!
			// Animation breath:
			sleep 0.5;
			// Delete the veh:
			deleteVehicle _veh;
			// Debug message:
			if SD_isOnDebugGlobal then { format ["%1 ANTI-ROLLOVER > '%2' has been deleted.", SD_warnHeader, typeOf _veh] call BIS_fnc_error };
		};
	// If somehow the veh blew up:
	} else {
		// If there's crew:
		if (count _crew > 0) then {
			// Message to the crew (Mandatory):
			[format ["%1 Auto-removal canceled.", SD_alertHeader]] remoteExec ["systemChat", _crew];
		} else {
			// Debug message:
			if SD_isOnDebugGlobal then { systemChat format ["%1 ANTI-ROLLOVER > Auto-removal canceled to '%2'.", SD_debugHeader, typeOf _veh] };
		};
		// Delete the wreck, if inside the zone:
		if ( _veh distance _zonePos <= _rng ) then { deleteVehicle _veh };
	};
	// Return:
	true;
};


THY_fnc_SD_protection_equipment = {
	// This function ...
	// Returns nothing.

	params ["_side", "_veh", "_zonesBySide"];
	private ["_zone", "_rng", "_zonePos", "_zoneBooked"];

	// Escape:
		// Reserved space;
	// Initial values:
	_zone       = "";
	_rng        = 0;
	_zonePos    = [];
	_zoneBooked = "";
	// Declarations:
		// Reserved space.
	//
	switch _side do {
		case BLUFOR:      { _zonesBySide = _zonesBySide # 0 };
		case OPFOR:       { _zonesBySide = _zonesBySide # 1 };
		case INDEPENDENT: { _zonesBySide = _zonesBySide # 2 };
		case CIVILIAN:    { _zonesBySide = _zonesBySide # 3 };
	};
	// If veh still in-game:
	while { alive _veh } do {
		{  // forEach _zonesBySide:
			// Internal Declarations:
			_zone    = _x # 0;
			_rng     = _x # 1;
			_zonePos = _x # 2;
			// If this zone-marker is NOT already booked:
			if ( _zone isNotEqualTo _zoneBooked ) then {
				// if inside the protection range:
				if ( _veh distance _zonePos <= _rng ) then {
					// Makes vehicle unbreakable:
					_veh allowDamage false;
					// It does the booking:
					_zoneBooked = _zone;
					// wait until the veh (somehow) explodes, or get far away from zone, or roll over:
					waitUntil { sleep SD_checkDelay; !alive _veh || _veh distance _zonePos > _rng || (vectorUp _veh # 2) < SD_leanLimit };
					// If vehicle still alive:
					if ( alive _veh ) then {
						// still inside the zone:
						if ( _veh distance _zonePos <= _rng ) then {
							// If veh rolled over:
							if ( (vectorUp _veh # 2) < SD_leanLimit ) then {
								[_veh, _rng, _zonePos] call THY_fnc_SD_equipment_autoRemoval;
							};
						// Otherwise, if out of zone:
						} else {
							// Restores the _veh original fragility:
							_veh allowDamage true;
							// Undone the booking:
							_zoneBooked = "";
						};
					// if vehicle is destroyed:
					} else {
						// Delete the wreck, if inside the zone:
						if ( _veh distance _zonePos <= _rng ) then { deleteVehicle _veh };
					};
				};
				// CPU breath:
				sleep SD_checkDelay;
			};
			// Breath:
			sleep 0.2;
		} forEach _zonesBySide;
	};  // While-loop ends.
	// Return:
	true;
};


THY_fnc_SD_protection_aiUnit = {
	// This function ...
	// Returns nothing.

	params ["_side", "_ai", "_zonesBySide"];
	private ["_zone", "_rng", "_zonePos", "_zoneBooked"];

	// Escape:
		// Reserved space;
	// Initial values:
	_zone       = "";
	_rng        = 0;
	_zonePos    = [];
	_zoneBooked = "";
	// Declarations:
		// Reserved space.
	//
	switch _side do {
		case BLUFOR:      { _zonesBySide = _zonesBySide # 0 };
		case OPFOR:       { _zonesBySide = _zonesBySide # 1 };
		case INDEPENDENT: { _zonesBySide = _zonesBySide # 2 };
		case CIVILIAN:    { _zonesBySide = _zonesBySide # 3 };
	};
	// If veh still in-game:
	while { alive _ai } do {
		{  // forEach _zonesBySide:
			// Internal Declarations:
			_zone    = _x # 0;
			_rng     = _x # 1;
			_zonePos = _x # 2;
			// If this zone-marker is NOT already booked:
			if ( _zone isNotEqualTo _zoneBooked ) then {
				// if inside the protection range:
				if ( _ai distance _zonePos <= _rng ) then {
					// Makes _ai immortal:
					_ai allowDamage false;
					// It does the booking:
					_zoneBooked = _zone;
					// wait until the veh (somehow) explodes, or get far away from zone, or roll over:
					waitUntil { sleep SD_checkDelay; !alive _ai || _ai distance _zonePos > _rng };
					// If _ai still alive:
					if ( alive _ai && _ai distance _zonePos > _rng ) then {
						// Restores _ai mortality:
						_ai allowDamage true;
						// Undone the booking:
						_zoneBooked = "";
					};
				};
				// CPU breath:
				sleep SD_checkDelay;
			};
			// Breath:
			sleep 0.2;
		} forEach _zonesBySide;
	};  // While-loop ends.
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
			\n
			\n---
			\n
			\nAre you protected: %3
			\n%10
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
			if SD_isOnZeusWhenDebug then {"ON"} else {"OFF"},
			if (!isNull (objectParent _unit)) then {if (isDamageAllowed (objectParent _unit)) then {"Is your veh protected: NOPE!\n"} else {"Is your veh protected: YES!\n"} } else {""}
		];
		// Breath:
		sleep 3;
	};
	// Return:
	true;
};
// Return:
true;
