// Read the current roster only from the authoritative campaign namespace.
if (!isServer || {!isRemoteExecuted} || {remoteExecutedOwner <= 2}) exitWith {};
params [["_namespace",objNull,[objNull]],["_marker","",[""]]];
if (isNil "garrison" || {isNull _namespace} || {_namespace isNotEqualTo garrison} || {_marker == ""}) exitWith {};
[_namespace,_marker,+(_namespace getVariable [_marker,[]])]
    remoteExecCall ["A3URF_fnc_receiveGarrison",remoteExecutedOwner];
