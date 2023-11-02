// SUPER DOME v1.2
// File: your_mission\superDome\fn_SD_clientSide.sqf
// Documentation: your_mission\superDome\_SD_Documentation.pdf
// by thy (@aldolammel)


if !hasInterface exitWith {};

// Escape:
if ( !SD_isOnSuperDome || !SD_isProtectedPlayer ) exitWith {};

//params [""];
private ["_mkr", "_mkrPos", "_rng", "_mkrBooked", "_sideZonesCollection", "_debugMkr"];

// Initial values:
_mkr                 = objNull;
_mkrPos              = [];
_rng                 = nil; 
_mkrBooked           = "";
_sideZonesCollection = [];
_debugMkr            = "";
// Declarations:
SD_clientSideStatus = "ON";
publicVariable "SD_clientSideStatus";
// Setting each SD Protected Zones (Markers):
{  // forEach SD_zonesCollection:
	// If zone is from the same player's side:
	if ( (_x # 2) isEqualTo playerSide ) then {
		// Add as valid mkr for this player:
		_sideZonesCollection pushBack _x;
		// If it's to show the protected zones on the map:
		if ( SD_isOnDebugGlobal || SD_isOnShowMarkers ) then {
			// Marker position visible:
			(_x # 0) setMarkerAlpha 1;
			// Set an uncommitted visible protection range:
			_debugMkr = createMarker ["SD_RANGE_"+(_x # 0), getMarkerPos (_x # 0)];
			_debugMkr setMarkerShape "ELLIPSE";
			_debugMkr setMarkerSize [(_x # 1), (_x # 1)];
			_debugMkr setMarkerBrush "Border";
			_debugMkr setMarkerColor "ColorWhite";
			_debugMkr setMarkerAlpha 1;
			//_debugMkr setMarkerDrawPriority 1;  // WIP
		};
	};
} forEach SD_zonesCollection;
// Debug message:
if SD_isOnDebugGlobal then {
	systemChat format ["%1 Server-side status: .. %2", SD_debugHeader, SD_serverSideStatus];
	systemChat format ["%1 Client-side status: .. ON (%2)", SD_debugHeader, name player];
	systemChat format ["%1 Your side (%2) has %3 protected zones.", SD_debugHeader, playerSide, count _sideZonesCollection];
};
// Wait for the player be alive on the map:
waitUntil { sleep 1; !isNull player };
// Debug:
if SD_isOnDebugGlobal then {
	// Shows the SD monitor:
	[player] spawn THY_fnc_SD_debugMonitor;
};
// Looping to check the protected zones:
while { SD_isProtectedPlayer && alive player } do {
	{  // forEach _sideZonesCollection:
		// Internal Declarations:
		_mkr    = _x # 0;
		_mkrPos = getMarkerPos _mkr;
		_rng    = _x # 1;

		systemChat format ["Aqui: %1", _mkrBooked];

		// If this zone-marker is NOT already booked:
		if ( _mkr isNotEqualTo _mkrBooked ) then {
			// if player is into the base range, respecting the speed limit:
			if ( player distance _mkrPos <= _rng && abs (speed player) < SD_speedLimit ) then {
				// Makes player immortal:
				player allowDamage false;
				// It does the booking:
				_mkrBooked = _mkr;
				// Message:
				if ( SD_isOnDebugGlobal || SD_isOnAlerts ) then {
					systemChat format ["%1 You're in a protected zone%2.",
					SD_alertHeader, if SD_isOnDebugGlobal then {" ("+_mkr+")"} else {""}];
					// Message breath:
					sleep 1;
				};
			};
		// If this zone-marker is already booked:
		} else {
			// if player is out of the current booked zone:
			if ( _mkr isEqualTo _mkrBooked && player distance _mkrPos > _rng ) then {
				// Restores the player mortality:
				player allowDamage true;
				// Undo the booking:
				_mkrBooked = "";
				// Message:
				if ( SD_isOnDebugGlobal || SD_isOnAlerts ) then {
					systemChat format ["%1 You left the protected zone%2.",
					SD_alertHeader, if SD_isOnDebugGlobal then {" ("+_mkr+")"} else {""}]; 
					// Message breath:
					sleep 1;
				};
			};
		};
		// Breath:
		sleep 0.2;
	} forEach _sideZonesCollection;
	// CPU breath:
	sleep SD_checkDelay;
}; // while-looping ends.
// Return:
true;
