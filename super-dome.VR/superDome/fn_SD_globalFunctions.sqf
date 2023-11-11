// SUPER DOME v1.5.1
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


THY_fnc_SD_isUsing_respawn = {
	// This function checks if the object is using the Arma Respawn Vehicle Module.
	// Returns _isUsing: bool.

	params ["_obj", ["_isOnMsg", true]];
	private ["_isUsing"];

	// Initial values:
	_isUsing = false;
	// Declarations:
		// Reserved space;
	// Main function:
	if ( !(_obj getVariable ["BIS_fnc_moduleRespawnVehicle_first", false]) && !isNil { _obj getVariable "BIS_fnc_moduleRespawnVehicle_mpKilled" } ) then { _isUsing = true };
	// Debug:
	if ( SD_isOnDebugGlobal && SD_isDebugDeeper && _isOnMsg ) then {
		// Server message:
		systemChat format ["> %1 > Respawn detected = %2.", typeOf _obj, if _isUsing then {"YES"} else {"NO"}];
	};
	// Return:
	_isUsing;
};


/* THY_fnc_SD_canFloat = {
	// This function checks if the object/vehicle are able to float.
	// Returns _canFloat: bool

	params ["_obj"];
	private ["_canFloat", "_floatVal"];

	// Initial values:
	_canFloat = false;
	// Declarations:
		// Reserved space;
	// Main function:
	_floatVal = _obj getVariable ['TAG_canFloat', -1];
	if ( _floatVal isEqualTo -1 ) then {
		_floatVal = getNumber (configFile >> 'CfgVehicles' >> (typeOf _obj) >> 'canFloat');
		_obj setVariable ['TAG_canFloat', _floatVal];
	}; 
	_canFloat = _floatVal > 0;
	// Return:
	_canFloat;
}; */


THY_fnc_SD_wreck_cleaner = {
	// This function delete all unknown wrecks in the protected zone.
	// Returns nothing.

	params ["_zonePos", "_rng"];
	//private ["", "", ""];

	// Initial values:
		// Reserved space;
	// Declarations:
		// Reserved space;
	{  // Delete all potential wrecks:
		// Debug server message:
		if SD_isOnDebugGlobal then {
			systemChat format ["%1 ANTI-WRECK > '%2' was deleted!",
			SD_debugHeader, typeOf _x];
		};
		// Delete the thing:
		deleteVehicle _x;
		// Breather:
		sleep 0.5;
	} forEach (allDead select { _x distance2D _zonePos <= _rng && !(_x isKindOf "Man") && !(_x isKindOf "House") && vehicleVarName _x isEqualTo "" });  // Critical: this vehicleVarName == "" prevent SD to delete wrecks from vehicles that will be respawn by Eden Vehicles Respawn module. If we delete those, that module lost the object reference.
	// Return:
	true;
};


THY_fnc_SD_protection_equipment = {
	// This function protects individualy each equipment (vehicle or static weapon) when inside of the range of all zones from the same side of the zone originally scanning the equipment at the mission starts.
	// Param: _obj: vehicle or static weapon.
	// Returns nothing.

	params ["_zonesBySide", "_obj"];
	private ["_rng", "_zonePos", "_var", "_crew", "_isToRspwn"/* , "_canFloat" */];

	// Escape:
		// Reserved space;
	// Initial values:
	_rng     = 0;
	_zonePos = [];
	_var     = vehicleVarName _obj;
	_crew    = [];
	// Declarations:
	_isToRspwn = [_obj] call THY_fnc_SD_isUsing_respawn;
	//_canFloat  = [_obj] call THY_fnc_SD_canFloat;
	// If _obj still in-game:
	while { alive _obj || _isToRspwn } do {
		// if this equipment should be covered by respawn system:
		if _isToRspwn then {
			// WIP - Check how to know how much respawns are available if the Editor has set a limit respawn number in Arma Respawn Vehicle Module... Important to stop this thread when the equipment won't be spawned again!
			// If the object was destroyed, here is where we address the new-object to the original varName:
			_obj = missionNamespace getVariable _var;
		};
		// Escape > Stop the looping if after the getVariable fail or, e.g., Zeus delete the equipment (WIP = work to dont stop the thread if zeus force the veh delete):
		if ( isNull _obj ) then { break };
		// Escape > If Eden Vehicles Respawn is enabled for this equipment, but the equipment is destroyed, wait a while until respawn the while-loop:
		if ( _isToRspwn && !alive _obj ) then { sleep SD_checkDelay; continue };
		// Debug server message:
		if ( SD_isOnDebugGlobal && SD_isDebugDeeper ) then { systemChat format ["> '%1' searching protection...", str _obj] };
		//
		{  // forEach _zonesBySide:
			// Internal Declarations:
			_rng     = _x # 1;
			_zonePos = _x # 2;
			// if inside the protection range:
			if ( _obj distance _zonePos <= _rng ) then {
				// if respecting the speed limit:
				if ( abs (speed _obj) <= SD_speedLimit && abs ((velocity _obj) # 2) <= SD_velocityLimit ) then {
					// Makes _obj unbreakable:
					_obj allowDamage false;
					// wait until the _obj (somehow) explodes, or get far away from zone, or exceed the speed limit, or rollover:
					waitUntil {
						// Looping breather:
						sleep SD_checkDelay;
						// Debug server message:
						if ( SD_isOnDebugGlobal && SD_isDebugDeeper && objectParent player isEqualTo _obj && !isNull _obj ) then { systemChat format ["> '%1' (w/ %2) keeps on standby.", typeOf _obj, name player] };
						// If obj's dead:
						!alive _obj ||
						// If obj's not in zone:
						_obj distance _zonePos > _rng ||
						// if obj exceeded horizontal speed limit:
						abs (speed _obj) > SD_speedLimit ||
						// if obj exceeded vertical speed limit:
						abs ((velocity _obj) # 2) > SD_velocityLimit ||
						// if obj exceeded leaning limit:
						(vectorUp _obj # 2) < SD_leanLimit
					};
					// If _obj still alive:
					if ( alive _obj ) then {
						// still inside the zone, and respecting the speed limit:
						if ( _obj distance _zonePos <= _rng && abs (speed _obj) <= SD_speedLimit && abs ((velocity _obj) # 2) <= SD_velocityLimit ) then {
							// If _obj rolled over:
							if ( (vectorUp _obj # 2) < SD_leanLimit ) then {
								// Wait to see if it was just a scary manuever:
								sleep 8;
								// Escape if everything is fine, otherwise, keep the punishment:
								if ( (vectorUp _obj # 2) >= SD_leanLimit ) exitWith {};
								// Restores the _obj original fragility:
								_obj allowDamage true;
								// take the current crew (but considering only the human ones):
								_crew = ((crew _obj) select { alive _x && isPlayer _x }) - entities "HeadlessClient_F";
								// if there are players as crew:
								if ( count _crew > 0 ) then {
									// Force the crew (alive or unconscious) to leave the vehicle:
									{ moveOut _x } forEach _crew;
									// Precaution, locking the equipment for players:
									_obj lock 3;
									// Mandatory player message:
									[format ["%1 ANTI-ROLLOVER > For zone integrity, your equipment has been destroyed.", SD_alertHeader]] remoteExec ["systemChat", _crew];
								// If no players as crew:
								} else {
									// If debug is on, warning server message:
									if SD_isOnDebugGlobal then {
										systemChat format ["%1 ANTI-ROLLOVER > '%2' (%3) has been destroyed.", SD_warnHeader, str _obj, typeOf _obj];
									};
								};
								// If the equipement will spawn:
								if _isToRspwn then {
									// Breather for player get far away from the fire will come:
									sleep 2;
									// Destroy the vehicle:
									// Critical: never delete the vehicle when Eden Verhicles Respawn is working. The wreck will be managed by that module.
									_obj setDamage [1, false];
								// Otherwise:
								} else {
									// Delete equipment to not leave a wreck:
									deleteVehicle _obj;
								};
								// Stop the forEach:
								break;
							};
						// Otherwise, if out of zone:
						} else {
							// Restores the _obj original fragility:
							_obj allowDamage true;
						};
					// if _obj is destroyed:
					} else {
						// Delete the wreck, if inside the zone:
						// Critical: don't delete this wreck if Eden Respawn Vehicle is activated (_isToRspwn) because the module will
								// track this wreck and, if SD delete it, the ERV will lost the objet and SD will badly finish the thread!
						if ( !_isToRspwn && _obj distance _zonePos <= _rng ) then { 
							// Delete equipment:
							deleteVehicle _obj;
						};
					};
				};
			};
			// Breather:
			sleep SD_checkDelay;
		} forEach _zonesBySide;
	};  // While-loop ends.
	// Debug server message:
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
			// Breather:
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
			%12
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
			\nNew checks after: %15s
			\nSD player alerts: %7
			\nSD visible markers: %8
			\nSD stuff on Zeus: %9
			\n
			\n---
			\n
			\nAdditional protection: %13
			%14
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
			if (!isNull (objectParent _unit)) then {if ([objectParent _unit, false] call THY_fnc_SD_isUsing_respawn) then {"Respawn available for: YES\n"} else {"Respawn available for: NO\n"}} else {""},
			if SD_isDebugDeeper then {"\nExtra debug information: ON\n"} else {""},
			if SD_isOnAdditionalProtection then {"ON\nNew checks after: "} else {"OFF\n"},
			if SD_isOnAdditionalProtection then {(str SD_AdditionalProtectTimer) + "s\n"} else {""},
			SD_checkDelay
		];
		// Breather:
		sleep 3;
	};
	// Return:
	true;
};
// Return:
true;
