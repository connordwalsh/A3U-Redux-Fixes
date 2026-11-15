if (!isServer) exitWith {};
[] spawn {
    private _checks=0;private _failures=[];
    private _check={params ["_name","_passed",["_detail",[]]];
        _checks=_checks+1;if (!_passed) then {_failures pushBack _name};
        diag_log format ["[REDUX_POPULATION] %1",["check",_name,_passed,_detail]]};
    sleep 3;
    diag_log format ["[REDUX_POPULATION] %1",["start",worldName,isClass(configFile >> "CfgPatches" >> "A3URF_core"),productVersion]];
    ["independent_of_infection",!isClass(configFile >> "CfgPatches" >> "A3I_core")
        && {!isClass(configFile >> "CfgPatches" >> "WBK_ZombieCreatures")}] call _check;
    server=[true] call A3A_fnc_createNamespace;
    private _first=[false] call A3A_fnc_getCityData;
    private _second=[false] call A3A_fnc_getCityData;
    private _third=[false] call A3A_fnc_getCityData;
    private _towns=createHashMapFromArray (_first # 1);
    ["native_population_count",count (_first # 0)==49,[count (_first # 0)]] call _check;
    ["native_capital_population",(_towns get "Chernogorsk") # 0 == 1176,[_towns get "Chernogorsk"]] call _check;
    ["second_initialization_stable",_second isEqualTo _first] call _check;
    ["third_initialization_stable",_third isEqualTo _first] call _check;
    ["native_server_rows_restored",((_third # 1) findIf {
        !((server getVariable [_x # 0,[]]) isEqualTo (_x # 1))
    })==-1] call _check;
    deleteVehicle server;
    diag_log format ["[REDUX_POPULATION] %1",["complete",_checks,_failures]];
};
