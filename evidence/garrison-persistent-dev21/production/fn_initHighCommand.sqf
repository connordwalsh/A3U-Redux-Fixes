// Preserve the native main scope and native HC implementation. Redux can start
// with disabledAI and no commander, so defer only that empty synchronization case.
if (!isServer) exitWith {};
params ["_logic"];
if (isNil "BIS_HC_mainscope") then {
    BIS_HC_mainscope = _logic;
    publicVariable "BIS_HC_mainscope";
};
if (toLower worldName != "chernarusredux" || {is3DEN}) exitWith {
    _this execVM "\A3\modules_f\HC\data\scripts\hc.sqf"
};
if (_logic getVariable ["A3URF_hcScheduled",false]) exitWith {};
_logic setVariable ["A3URF_hcScheduled",true];
private _worker = [_logic] spawn {
    params ["_logic"];
    waitUntil {
        sleep 0.25;
        isNull _logic || {
            (synchronizedObjects _logic) findIf {typeOf _x != "HighCommandSubordinate"} != -1
        }
    };
    if (isNull _logic) exitWith {};
    private _native = [_logic] execVM "\A3\modules_f\HC\data\scripts\hc.sqf";
    _logic setVariable ["A3URF_hcNative",_native];
};
_logic setVariable ["A3URF_hcWorker",_worker];
