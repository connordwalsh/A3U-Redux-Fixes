if (!isServer) exitWith {};
[] spawn {
    sleep 3;
    private _before=activatedAddons;
    private _result=[];
    isNil {_result=[toUpper (_before select 0)] call BIS_fnc_activateAddons};
    diag_log format ["[REDUX_ACTIVATION] %1",["active_result",count _result,_result isEqualTo _before]];
    isNil {_result=[] call BIS_fnc_activateAddons};
    diag_log format ["[REDUX_ACTIVATION] %1",["empty_result",count _result,_result isEqualTo _before]];
    isNil {_result=["A3URF_nonexistent_activation_probe"] call BIS_fnc_activateAddons};
    diag_log format ["[REDUX_ACTIVATION] %1",["unknown_rejected",_result isEqualTo []]];
    isNil {_result=[123] call BIS_fnc_activateAddons};
    diag_log format ["[REDUX_ACTIVATION] %1",["wrong_type_rejected",_result isEqualTo []]];
    diag_log format ["[REDUX_ACTIVATION] %1",["active_set_unchanged",activatedAddons isEqualTo _before]];
    diag_log "[REDUX_ACTIVATION] complete";
};
