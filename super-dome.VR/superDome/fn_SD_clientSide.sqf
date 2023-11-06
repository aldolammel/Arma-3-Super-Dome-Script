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
			_zone setMarkerAlpha 1;
			// Set an uncommitted visible protection range:
			_rngMkr = createMarker ["SD_RANGE_"+_zone, getMarkerPos _zone];
			_rngMkr setMarkerShape "ELLIPSE";
			_rngMkr setMarkerSize [_rng, _rng];
			_rngMkr setMarkerBrush "Border";
			_rngMkr setMarkerColor "ColorWhite";
			_rngMkr setMarkerAlpha 1;
			//_rngMkr setMarkerDrawPriority 1;  // WIP
		};
	};
} forEach SD_zonesCollection;
// Debug message:
if SD_isOnDebugGlobal then {
	systemChat format ["%1 Server-side status: .. %2", SD_debugHeader, SD_serverSideStatus];
	systemChat format ["%1 Client-side status: .. ON (%2)", SD_debugHeader, name _unit];
	systemChat format ["%1 Your side (%2) has %3 protected zones.", SD_debugHeader, playerSide, count _sideZones];
};
// Wait for the _unit be alive on the map:
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
			// if respecting the speed limit:
			if ( abs (speed _unit) <= SD_speedLimit ) then {
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
				waitUntil { sleep SD_checkDelay; !alive _unit || _unit distance _zonePos > _rng || abs (speed _unit) > SD_speedLimit };
				// Restores the _unit mortality:
				_unit allowDamage true;
				// Message:
				if ( SD_isOnDebugGlobal || SD_isOnAlerts ) then {
					systemChat format ["%1 You left the protected zone%2.",
					SD_alertHeader, if SD_isOnDebugGlobal then {" (" + _zone + ")"} else {""}]; 
					// Message breath:
					sleep 1;
				};
			} else {
				// Warning:
				if ( SD_isOnDebugGlobal || SD_isOnAlerts ) then {
					// Message:
					systemChat format ["%1 Protection disabled for a while: speed over to %2Km/h.", SD_alertHeader, SD_speedLimit];
				}
			};
		};
		// Breath:
		sleep SD_checkDelay;
	} forEach _sideZones;
}; // while-looping ends.
// Return:
true;
