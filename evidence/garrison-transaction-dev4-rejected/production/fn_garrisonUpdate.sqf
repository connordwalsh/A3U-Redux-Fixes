// Keep Ultimate's ownership, role conversion and roster update rules intact.
// Scheduled scripts can yield between its mutex test and acquisition, allowing
// concurrent updates to overwrite a newer roster with an older local snapshot.
if (!isServer) exitWith {};
private _trace=false;
isNil {
    if (missionNamespace getVariable ["A3URF_garrisonTrace",false]) then {
        private _n=missionNamespace getVariable ["A3URF_traceSeen",0];
        _trace=_n<20;
        A3URF_traceSeen=_n+1;
    };
};
if (_trace) then {diag_log format ["[GARRISON_TRANSACTION] enter %1",[canSuspend,diag_frameNo,_this,garrisonIsChanging,count (garrison getVariable [_this # 2,[]])]]};
if (!canSuspend) exitWith {_this spawn A3A_fnc_garrisonUpdate};
private _updated = false;
waitUntil {
    // Acquire and perform the native read/modify/write without a scheduling
    // boundary. Never enter its waitUntil while the shared mutex is occupied.
    isNil {
        if (!garrisonIsChanging) then {
            if (_trace) then {diag_log format ["[GARRISON_TRANSACTION] before %1",[canSuspend,diag_frameNo,_this,garrisonIsChanging,count (garrison getVariable [_this # 2,[]])]]};
            private _result=_this call A3URF_fnc_originalGarrisonUpdate;
            if (_trace) then {diag_log format ["[GARRISON_TRANSACTION] after %1",[canSuspend,diag_frameNo,_this,garrisonIsChanging,count (garrison getVariable [_this # 2,[]]),if (isNil "_result") then {"nil"} else {typeName _result}]]};
            _updated = true;
        };
    };
    _updated
};
