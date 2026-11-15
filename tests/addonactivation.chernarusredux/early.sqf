if (!isServer) exitWith {};
diag_log "[REDUX_ACTIVATION] start";
private _before=activatedAddons;
private _result=[_before select 0] call BIS_fnc_activateAddons;
diag_log format ["[REDUX_ACTIVATION] %1",["early_native",time==0 && {_result isEqualTo activatedAddons} && {count _result>=count _before}]];
