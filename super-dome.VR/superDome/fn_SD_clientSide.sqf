// SUPER DOME v1.2
// File: your_mission\superDome\fn_SD_clientSide.sqf
// Documentation: your_mission\superDome\_SD_Documentation.pdf
// by thy (@aldolammel)


if !hasInterface exitWith {};

// Escape:
if ( !SD_isOnSuperDome || !SD_isProtectedPlayer ) exitWith {};

params ["_unit"];
private ["_zone", "_zonePos", "_zoneBooked", "_rng", "_rngMkr", "_sideZones"];

// Initial values:
_zone       = objNull;
_zonePos    = [];
_zoneBooked = "";
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
		// If this zone-marker is NOT already booked:
		if ( _zone isNotEqualTo _zoneBooked ) then {
			// if _unit is into the base range, respecting the speed limit:
			if ( _unit distance _zonePos <= _rng && abs (speed _unit) <= SD_speedLimit ) then {
				// Makes _unit immortal:
				_unit allowDamage false;
				// It does the booking:
				_zoneBooked = _zone;
				// Message:
				if ( SD_isOnDebugGlobal || SD_isOnAlerts ) then {
					systemChat format ["%1 You're in a protected zone%2.",
					SD_alertHeader, if SD_isOnDebugGlobal then {" ("+_zone+")"} else {""}];
					// Message breath:
					sleep 1;
				};
				// 
				waitUntil { sleep SD_checkDelay; !alive _unit || _unit distance _zonePos > _rng || abs (speed _unit) > SD_speedLimit };
				// Restores the _unit mortality:
				_unit allowDamage true;
				// Undone the booking:
				_zoneBooked = "";
				// Message:
				if ( SD_isOnDebugGlobal || SD_isOnAlerts ) then {
					systemChat format ["%1 You left the protected zone%2.",
					SD_alertHeader, if SD_isOnDebugGlobal then {" ("+_zone+")"} else {""}]; 
					// Message breath:
					sleep 1;
				};
			};
		};
		// Breath:
		sleep 0.2;
	} forEach _sideZones;
	// CPU breath:
	sleep SD_checkDelay;
}; // while-looping ends.
// Return:
true;
