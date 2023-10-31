// SUPER DOME v1.0
// File: your_mission\superDome\fn_SD_globalFunctions.sqf
// Documentation: your_mission\superDome\_SD_Documentation.pdf
// by thy (@aldolammel)


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
		\nAre u protected: %3
		\nProtected by: WIP
		\n
		\n------
		\n
		\nPlayers protected: %4
		\nVehs protected: %5
		\nAI grps protected: %6
		\n",
		name _unit, playerSide, if (isDamageAllowed _unit) then {"NO"} else {"YES"}, SD_isProtectedPlayer, SD_isProtectedVehicle, SD_isProtectedAI
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
