// Serialize callers, while retaining Ultimate's scheduled update and publication.
if (!isServer) exitWith {};
if (!canSuspend) exitWith {_this spawn A3A_fnc_garrisonUpdate};
private _acquired = false;
waitUntil {
    isNil {
        if !(missionNamespace getVariable ["A3URF_garrisonBusy",false]) then {
            A3URF_garrisonBusy = true;
            _acquired = true;
        };
    };
    _acquired
};
// Keep the native call scheduled: publication inside an unscheduled transaction
// failed the diagnostic. The entry lock admits only one native writer at a time.
_this call A3URF_fnc_originalGarrisonUpdate;
A3URF_garrisonBusy = false;
