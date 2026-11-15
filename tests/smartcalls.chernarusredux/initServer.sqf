if (!isServer) exitWith {};
[] spawn {
    sleep 3;
    // Native get-marker-name request without an initialized module must still fail.
    private _result = true;
    isNil {_result = [2,["A3URF_missing_marker"]] call BIS_fnc_OM_moduleSmartMarkers};
    diag_log format ["[REDUX_SMART_CALL] %1",["uninitialized_request",_result isEqualTo false,isNil "BIS_OM_SmartMarkers_logic"]];
    diag_log "[REDUX_SMART_CALL] complete";
};
