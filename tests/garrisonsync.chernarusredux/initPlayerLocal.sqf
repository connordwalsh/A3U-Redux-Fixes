if (isServer) exitWith {};
[] spawn {
    waitUntil {sleep 0.1;!isNil "garrison" && {!isNull garrison}};
    sleep 2;
    A3URF_syncJIP=[clientOwner,didJIP,garrison getVariable ["sync_regression",[]]];
    diag_log format ["[GARRISON_SYNC_CLIENT] jip %1",A3URF_syncJIP];
    publicVariableServer "A3URF_syncJIP";
    waitUntil {sleep 0.1;missionNamespace getVariable ["A3URF_syncStage",false]};
    sleep 1;
    A3URF_syncLive=[clientOwner,garrison getVariable ["sync_regression",[]]];
    diag_log format ["[GARRISON_SYNC_CLIENT] live %1",A3URF_syncLive];
    publicVariableServer "A3URF_syncLive";
};
