// Keep Ultimate's ownership, role conversion and roster update rules intact.
// Scheduled scripts can yield between its mutex test and acquisition, allowing
// concurrent updates to overwrite a newer roster with an older local snapshot.
if (!isServer) exitWith {};
if (!canSuspend) exitWith {_this spawn A3A_fnc_garrisonUpdate};
private _updated = false;
waitUntil {
    // Acquire and perform the native read/modify/write without a scheduling
    // boundary. Never enter its waitUntil while the shared mutex is occupied.
    isNil {
        if (!garrisonIsChanging) then {
            _this call A3URF_fnc_originalGarrisonUpdate;
            _updated = true;
        };
    };
    _updated
};
