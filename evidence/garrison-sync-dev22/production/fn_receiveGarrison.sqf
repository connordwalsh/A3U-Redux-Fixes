// Accept only server-originated deliveries. Never write on the server.
if (isServer || {!isRemoteExecuted} || {remoteExecutedOwner != 2}) exitWith {};
params [["_namespace",objNull,[objNull]],["_marker","",[""]],["_roster",[],[[]]]];
if (isNull _namespace || {_marker == ""}) exitWith {};
if (isRemoteExecutedJIP) exitWith {
    // Other native systems can reset/capture/load this marker after the last
    // garrisonUpdate. The persistent call is a request token, not saved state.
    [_namespace,_marker] remoteExecCall ["A3URF_fnc_sendGarrison",2];
};
_namespace setVariable [_marker,_roster,false];
