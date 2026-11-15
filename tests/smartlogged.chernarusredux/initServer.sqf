if (!isServer) exitWith {};
[] spawn {
    sleep 3;
    diag_log format ["[REDUX_SMART] %1",["state",getNumber(missionConfigFile >> "allowFunctionsLog"),isDedicated,count allPlayers,isNil "BIS_OM_SmartMarkers_logic",isNil "BIS_fnc_OM_moduleSmartMarkers"]];
    diag_log "[REDUX_SMART] complete";
};
