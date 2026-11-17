// The installed Old Man handler registers preInit but does not implement that mode.
// Only skip the exact engine lifecycle call on Redux; keep real operations native.
if (toLower worldName == "chernarusredux" && {_this isEqualTo ["preInit"]}) exitWith {false};
_this call A3URF_fnc_originalSmartMarkers
