if (!isServer) exitWith {};
[] spawn {
    sleep 3;
    A3URF_publicationNamespace=[true] call A3A_fnc_createNamespace;
    A3URF_publicationNamespace setVariable ["global_value",[11],true];
    A3URF_publicationNamespace setVariable ["excluded_value",[22],false];
    A3URF_publicationNamespace setVariable ["excluded_value",[22],-2];
    publicVariable "A3URF_publicationNamespace";
    diag_log format ["[REDUX_TRANSPORT] ready %1",[time,clientOwner,netId A3URF_publicationNamespace]];
    private _until=diag_tickTime+180;
    waitUntil {sleep 0.1;!isNil "A3URF_publicationJIP" || {diag_tickTime>=_until}};
    if (isNil "A3URF_publicationJIP") exitWith {diag_log "[REDUX_TRANSPORT] timeout_jip"};
    diag_log format ["[REDUX_TRANSPORT] jip %1",A3URF_publicationJIP];
    A3URF_publicationNamespace setVariable ["global_value",[33],true];
    A3URF_publicationNamespace setVariable ["excluded_value",[44],false];
    A3URF_publicationNamespace setVariable ["excluded_value",[44],-2];
    A3URF_publicationNamespace setVariable ["live",true,true];
    _until=diag_tickTime+30;
    waitUntil {sleep 0.1;!isNil "A3URF_publicationLive" || {diag_tickTime>=_until}};
    if (isNil "A3URF_publicationLive") exitWith {diag_log "[REDUX_TRANSPORT] timeout_live"};
    diag_log format ["[REDUX_TRANSPORT] live %1",A3URF_publicationLive];
    diag_log format ["[REDUX_TRANSPORT] server %1",[
        A3URF_publicationNamespace getVariable ["global_value",[]],
        A3URF_publicationNamespace getVariable ["excluded_value",[]]]];
    diag_log "[REDUX_TRANSPORT] complete";
};
