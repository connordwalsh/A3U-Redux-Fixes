// Redux's original HQ attribute removes backpack network objects before their
// startup registration finishes. Defer this exact empty-inventory request until
// simulation starts; all other uses retain the installed native implementation.
private _defer = isServer && {time == 0} && {toLower worldName == "chernarusredux"}
    && {missionName == "Antistasi_chernarusredux"} && {_this isEqualType []}
    && {count _this == 2} && {(_this select 0) isEqualType objNull}
    && {(_this select 1) isEqualTo ""};
if (_defer) then {
    private _crate = _this select 0;
    _defer = !isNull _crate && {local _crate} && {typeOf _crate == "IG_supplyCrate_F"}
        && {_crate distance2D [381.93536,4843.8149] < 0.5};
};
if (!_defer) exitWith {_this call A3URF_fnc_originalInitAmmoBox};
private _crate = _this select 0;
if (_crate getVariable ["A3URF_hqCargoScheduled",false]) exitWith {};
_crate setVariable ["A3URF_hqCargoScheduled",true];
private _worker = [_crate] spawn {
    params ["_crate"];
    waitUntil {isNull _crate || {time > 0}};
    if (isNull _crate || {!local _crate}) exitWith {};
    // Explicit native empty-cargo format avoids compiling an empty string into
    // an undefined value when the deferred call executes in scheduled context.
    [_crate,[[[[],[]],[[],[]],[[],[]],[[],[]]],false]] call A3URF_fnc_originalInitAmmoBox;
    _crate setVariable ["A3URF_hqCargoCleared",true];
};
_crate setVariable ["A3URF_hqCargoWorker",_worker];
