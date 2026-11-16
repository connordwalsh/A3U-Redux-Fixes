// Adapted from Ultimate 12.4.2 garrisonUpdate (MIT; bundled attribution).
// Preserve native role/ownership rules; serialize the complete roster mutation.
if (!isServer) exitWith {};
if (!canSuspend) exitWith {_this spawn A3A_fnc_garrisonUpdate};
params ["_typeX", "_sideX", "_markerX", "_modeX"];
if (isNil "_typeX" || {isNil "_sideX"} || {isNil "_markerX"} || {isNil "_modeX"}) exitWith {};
if !(_markerX isEqualType "") exitWith {};
if (_typeX isEqualType []) then {
    if (_typeX isNotEqualTo [] && {(_typeX # 0) isEqualType objNull}) then {
        _typeX = _typeX apply {_x getVariable "unitType"};
    };
} else {
    if (_typeX isEqualType objNull) then {_typeX = _typeX getVariable "unitType"};
};
if (isNil "_typeX") exitWith {};
private _finished = false;
private _changed = false;
waitUntil {
    isNil {
        if (!garrisonIsChanging) then {
            garrisonIsChanging = true;
            // Ownership is checked after acquiring the mutex, as in Ultimate.
            if (!(_sideX in [Occupants,Invaders,teamPlayer])
                || {sidesX getVariable [_markerX,sideUnknown] == _sideX}) then {
                private _roster = +(garrison getVariable [_markerX,[]]);
                if (_modeX == -1) then {
                    private _index = _roster find _typeX;
                    if (_index >= 0) then {_roster deleteAt _index};
                } else {
                    if (_modeX == 1) then {_roster pushBack _typeX} else {_roster append _typeX};
                };
                garrison setVariable [_markerX,_roster,false];
                // Live delivery excludes the authoritative server. JIP asks for
                // current state rather than replaying a potentially stale roster.
                [garrison,_markerX,_roster] remoteExecCall ["A3URF_fnc_receiveGarrison",-2,
                    format ["A3URF_garrison_%1_%2",netId garrison,_markerX]];
                _changed = true;
            };
            garrisonIsChanging = false;
            _finished = true;
        };
    };
    _finished
};
// Marker rendering need not hold the roster mutex or run unscheduled.
if (_changed && {_sideX == teamPlayer}) then {[_markerX] call A3A_fnc_mrkUpdate};
