// SUPER DOME v1.5
// File: your_mission\superDome\fn_SD_clientSide.sqf
// Documentation: your_mission\superDome\_SD_Documentation.pdf
// by thy (@aldolammel)


if !hasInterface exitWith {};

// Escape:
if ( !SD_isOnSuperDome || !SD_isProtectedPlayer ) exitWith {};

params ["_unit"];
private ["_zone", "_zonePos", "_rng", "_rngMkr", "_sideZones"];

// Initial values:
_zone       = objNull;
_zonePos    = [];
_rng        = 0;
_rngMkr     = "";
_sideZones  = [];
// Declarations:
SD_clientSideStatus = "ON";
publicVariable "SD_clientSideStatus";
// Setting each SD Protected Zones (Markers):
{  // forEach SD_zonesCollection:
	// Internal Declarations:
	_zone = _x # 0;
	_rng  = _x # 1;
	// If zone is from the same _unit's side:
	if ( (_x # 2) isEqualTo playerSide ) then {
		// Add as valid zone for this _unit:
		_sideZones pushBack [_zone, _rng];
		// If it's to show the protected zones on the map:
		if ( SD_isOnDebugGlobal || SD_isOnShowMarkers ) then {
			// Marker position visible:
			if SD_isOnDebugGlobal then { _zone setMarkerAlphaLocal 1 } else { _zone setMarkerAlphaLocal 0 };  // Critical for when player changes their team.
			// Set an uncommitted visible protection range:
			_rngMkr = createMarkerLocal ["SD_RANGE_"+_zone, getMarkerPos _zone];
			_rngMkr setMarkerShapeLocal "ELLIPSE";
			_rngMkr setMarkerSizeLocal [_rng, _rng];
			_rngMkr setMarkerBrushLocal "Border";
			_rngMkr setMarkerColorLocal "ColorWhite";
			_rngMkr setMarkerAlphaLocal 1;
		};
	};
} forEach SD_zonesCollection;
// Debug message:
if SD_isOnDebugGlobal then {
	systemChat format ["%1 Server-side status: .. %2", SD_debugHeader, SD_serverSideStatus];
	systemChat format ["%1 Client-side status: .. ON (%2)", SD_debugHeader, name _unit];
	systemChat format ["%1 Your side (%2) has %3 protected zones.", SD_debugHeader, playerSide, count _sideZones];
};
// Wait for the _unit be alive on the map to execute the codes right after this one below:
waitUntil { sleep 0.5; time > SD_wait && !isNull _unit };
// Debug:
if SD_isOnDebugGlobal then {
	// Shows the SD monitor:
	[_unit] spawn THY_fnc_SD_debugMonitor;
};
// Looping to check the protected zones:
while { alive _unit } do {
	{  // forEach _sideZones:
		// Internal Declarations:
		_zone    = _x # 0;
		_zonePos = getMarkerPos _zone;
		_rng     = _x # 1;
		// if _unit is into the base range:
		if ( _unit distance _zonePos <= _rng ) then {
			// if respecting the speed limit, and can breath regularly:
			if ( abs (speed _unit) <= SD_speedLimit && abs ((velocity _unit) # 2) <= SD_velocityLimit && isAbleToBreathe _unit ) then {
				// Makes _unit immortal:
				_unit allowDamage false;
				// Message:
				if ( SD_isOnDebugGlobal || SD_isOnAlerts ) then {
					systemChat format ["%1 You're in a protected zone%2.",
					SD_alertHeader, if SD_isOnDebugGlobal then {" (" + _zone + ")"} else {""}];
					// Message breath:
					sleep 1;
				};
				// Stay checking the unit until something break the checking:
				waitUntil {
					// Internal breath:
					sleep SD_checkDelay;
					// if unit's dead:
					!alive _unit ||
					// if unit's not in the zone:
					_unit distance _zonePos > _rng ||
					// if unit exceeded the horizontal speed:
					abs (speed _unit) > SD_speedLimit ||
					// if unit exceeded the vertical speed:
					abs ((velocity _unit) # 2) > SD_velocityLimit ||
					// if unit's deadly not breathing (underwater without diver gear):
					!isAbleToBreathe _unit
				};
				// Restores the _unit mortality:
				_unit allowDamage true;
				// Debug:
				if ( SD_isOnDebugGlobal || SD_isOnAlerts ) then {
					// If out of protected zone:
					if ( _unit distance _zonePos > _rng ) then {
						// Message:
						systemChat format ["%1 You left the protected zone%2.",
						SD_alertHeader, if SD_isOnDebugGlobal then {" (" + _zone + ")"} else {""}]; 
					// Otherwise:
					} else {
						// Message:
						systemChat format ["%1 You got broken a protection rule and are vulnerable.",
						SD_alertHeader];
					};
					
					// Message breath:
					sleep 1;
				};
			} else {
				// Warning:
				if ( SD_isOnDebugGlobal || SD_isOnAlerts ) then {
					if ( isAbleToBreathe _unit ) then {
						// Message:
						systemChat format ["%1 Protection compromised: exceeded speed limit.", SD_alertHeader];
					// Otherwise:
					} else {
						// Message:
						systemChat format ["%1 You got broken a protection rule and are vulnerable.",
						SD_alertHeader];
					};
				}
			};
		};
		// Breath:
		sleep SD_checkDelay;
	} forEach _sideZones;
}; // while-looping ends.
// Return:
true;
