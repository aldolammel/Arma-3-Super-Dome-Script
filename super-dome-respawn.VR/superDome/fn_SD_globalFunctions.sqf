// SUPER DOME v1.5
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
	// Wait to see if the veh not just rollovered once before return to a regular position:
	sleep 5;
	// Escape:
	if ( (vectorUp _veh # 2) >= SD_leanLimit ) exitWith {};
	// Initial values:
	_tol = 0;
	// If there's crew:
	if (count _crew > 0) then { 
		// Editor choice:
		_tol = SD_vehDelTolerance;
		// Player message (Mandatory):
		[format ["%1 %2 secs left to turn over the equipment before its auto-removal!", SD_warnHeader, _tol]] remoteExec ["systemChat", _crew];
	// If there is NO crew:
	} else {
		// Timeout is cutted by half:
		_tol = (SD_vehDelTolerance / 2);
		// Debug message for hosted server player (editor):
		if SD_isOnDebugGlobal then { systemChat format ["%1 ANTI-ROLLOVER > %2 secs left to auto-removal of '%3'.", SD_debugHeader, _tol, typeOf _veh] };
	};  
	// Declarations:
	_timeout = time + _tol;
	// Waiting until the timeout runs, or veh pos be fixed, or veh explode, or be moved to out of zone:
	waitUntil { sleep 5; time > _timeout || (vectorUp _veh # 2) >= SD_leanLimit || !alive _veh || _veh distance _zonePos > _rng };
	// If veh still alive (Zeus can force a explosion or throw the veh out of zone):
	if ( alive _veh ) then {
		// If somehow the veh gets out of zone (helicopter out of control, for example):
		if ( _veh distance _zonePos > _rng ) then { 
			// Restore the veh fragility:
			_veh allowDamage true;
		// If still in zone:
		} else {
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
	// This function protects individualy each equipment (vehicle or static weapon) when inside of all zones from the same side of the zone originally scanned the object in its range at the mission get started.
	// Param: _obj: vehicle or static weapon.
	// Returns nothing.

	params ["_zonesBySide", "_obj"];
	private ["_rng", "_zonePos", "_var", "_isOnForThisVeh"];

	// Escape:
		// Reserved space;
	// Initial values:
	_rng            = 0;
	_zonePos        = [];
	_var            = vehicleVarName _obj;
	_isOnForThisVeh = false; 
	// If the Mission Editor flags they have the intention to use Arma Respawn Vehicle Module on Eden, and...
	// also the Editor set a custom varName on this vehicle, OR, already synced the vehicle to the Arma Vehicle Module ("bis_oX_XXXX" automatic set to each obj synced there):
	// WIP : but if mission editor is using a custom varName and not syncing the object to the module, in this way it would be they're using to respawn but maybe is not the real case...
	if ( SD_isAcceptingRespawn && _var select [0, 7] isNotEqualTo "norspwn" ) then {
		// Probably this equipment must be respawned by Arma Respawn Vehicle Module when needed:
		_isOnForThisVeh = true;
	};
	// Declarations:
		// Reserved space;
	// If _obj still in-game:
	while { alive _obj || _isOnForThisVeh } do {
		// if this equipment should be covered by respawn system:
		if _isOnForThisVeh then {
			// WIP - Check how to know how much respawns are available if the Editor has set a limit respawn number in Arma Respawn Vehicle Module... Important to stop this thread when the equipment won't be spawned again!
			// Address a possible new-vehicle-object by the original varName:
			_obj = missionNamespace getVariable _var;
		};
		// Escape > Stop the looping (If Zeus delete the vehicle, for example, it will be NULL but still running if was a vehicle using a Respawn Vehicle Module):
		if ( isNull _obj ) then { break };
		// Debug message:
		//if SD_isOnDebugGlobal then { systemChat format ["Eqpnt: '%1' thread's running non-stop...", str _obj]};
		//
		{  // forEach _zonesBySide:
			// Internal Declarations:
			_rng     = _x # 1;
			_zonePos = _x # 2;
			// if inside the protection range:
			if ( _obj distance _zonePos <= _rng ) then {
				// if respecting the speed limit:
				if ( abs (speed _obj) <= SD_speedLimit ) then {
					// Makes _obj unbreakable:
					_obj allowDamage false;
					// wait until the _obj (somehow) explodes, or get far away from zone, or exceed the speed limit, or rollover:
					waitUntil {
						// Looping breath:
						sleep SD_checkDelay;
						// Debug message:
						//if ( SD_isOnDebugGlobal && objectParent player isEqualTo _obj ) then { systemChat format ["Eqpnt: '%1' (w/ %2) on standby...", str _obj, name player]};
						// Conditions to break the looping:
						!alive _obj || _obj distance _zonePos > _rng || abs (speed _obj) > SD_speedLimit || (vectorUp _obj # 2) < SD_leanLimit;
					};
					// If _obj still alive:
					if ( alive _obj ) then {
						// still inside the zone, and respecting the speed limit:
						if ( _obj distance _zonePos <= _rng && abs (speed _obj) <= SD_speedLimit ) then {
							// If _obj rollovered:
							if ( (vectorUp _obj # 2) < SD_leanLimit ) then {
								[_obj, _rng, _zonePos] call THY_fnc_SD_equipment_autoRemoval;
							};
						// Otherwise, if out of zone:
						} else {
							// Restores the _obj original fragility:
							_obj allowDamage true;
						};
					// if _obj is destroyed:
					} else {
						// Delete the wreck, if inside the zone:
						if ( _obj distance _zonePos <= _rng ) then { deleteVehicle _obj };
					};
				};
			};
			// Breath:
			sleep SD_checkDelay;
		} forEach _zonesBySide;
	};  // While-loop ends.
	// Debug message:
	if SD_isOnDebugGlobal then { systemChat format ["%1 An equipment thread was terminated!", SD_debugHeader]; sleep 3};
	// Return:
	true;
};


THY_fnc_SD_protection_aiUnit = {
	// This function protects individualy each AI unit when inside of all zones from the same side of the zone originally scanned the object in its range at the mission get started.
	// Param: _obj: AI unit.
	// Returns nothing.

	params ["_zonesBySide", "_obj"];
	private ["_zone", "_rng", "_zonePos"];

	// Escape:
		// Reserved space;
	// Initial values:
	_zone    = "";
	_rng     = 0;
	_zonePos = [];
	// Declarations:
		// Reserved space.
	// If veh still in-game:
	while { alive _obj } do {
		{  // forEach _zonesBySide:
			// Internal Declarations:
			_zone    = _x # 0;
			_rng     = _x # 1;
			_zonePos = _x # 2;
			// if inside the protection range:
			if ( _obj distance _zonePos <= _rng ) then {
				// Makes _obj immortal:
				_obj allowDamage false;
				// wait until the veh (somehow) explodes, or get far away from zone, or rollover:
				waitUntil { sleep SD_checkDelay; !alive _obj || _obj distance _zonePos > _rng };
				// If _obj still alive:
				if ( alive _obj && _obj distance _zonePos > _rng ) then {
					// Restores _obj mortality:
					_obj allowDamage true;
				};
			};
			// Breath:
			sleep SD_checkDelay;
		} forEach _zonesBySide;
	};  // While-loop ends.
	// Debug message:
	if SD_isOnDebugGlobal then { systemChat format ["%1 An AI thread was terminated!", SD_debugHeader]; sleep 3};
	// Return:
	true;
};


THY_fnc_SD_debugMonitor = {
	// show info on screen for each player with debug is true.
	// Returns nothing.

	params ["_unit"];
	//private [];

	// Escape:
	if !SD_isOnDebugGlobal exitWith {};
	
	while { alive _unit } do {
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
			%11
			\n---
			\n
			\nPlayers protection: %4
			\nVehs protection: %5
			\nAI protection: %6
			\nSD player alerts: %7
			\nSD visible markers: %8
			\nSD stuff on Zeus: %9
			\nSD accepting respawn: %12
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
			if (!isNull (objectParent _unit)) then {if (isDamageAllowed (objectParent _unit)) then {"Is your veh protected: NOPE!\n"} else {"Is your veh protected: YES!\n"}} else {""},
			if (SD_isAcceptingRespawn && !isNull (objectParent _unit)) then {if ((vehicleVarName (objectParent _unit)) select [0, 7] isEqualTo "norspwn") then {"Respawn available for: NO\n"} else {if ((vehicleVarName (objectParent _unit)) select [0, 5] isEqualTo "bis_o") then {"Respawn available for: YES\n"} else {"Respawn available for: NOT SURE\n"}}} else {""},
			if SD_isAcceptingRespawn then {"ON"} else {"OFF"}
		];
		// Breath:
		sleep 3;
	};
	// Return:
	true;
};
// Return:
true;