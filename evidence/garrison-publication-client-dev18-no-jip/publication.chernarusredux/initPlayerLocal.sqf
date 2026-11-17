diag_log format ["[REDUX_TRANSPORT_CLIENT] init %1",[isServer,hasInterface,clientOwner,didJIP]];
if (isServer) exitWith {};
[] spawn {
    waitUntil {sleep 0.1;!isNil "A3URF_publicationNamespace" && {!isNull A3URF_publicationNamespace}};
    sleep 2;
    A3URF_publicationJIP=[clientOwner,didJIP,time,
        A3URF_publicationNamespace getVariable ["global_value",[]],
        A3URF_publicationNamespace getVariable ["excluded_value",[]]];
    diag_log format ["[REDUX_TRANSPORT_CLIENT] jip %1",A3URF_publicationJIP];
    publicVariableServer "A3URF_publicationJIP";
    waitUntil {sleep 0.1;A3URF_publicationNamespace getVariable ["live",false]};
    sleep 1;
    A3URF_publicationLive=[clientOwner,
        A3URF_publicationNamespace getVariable ["global_value",[]],
        A3URF_publicationNamespace getVariable ["excluded_value",[]]];
    diag_log format ["[REDUX_TRANSPORT_CLIENT] live %1",A3URF_publicationLive];
    publicVariableServer "A3URF_publicationLive";
};
