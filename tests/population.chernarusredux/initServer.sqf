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
    if (toLower worldName != "chernarusredux") exitWith {
        private _native=[false] call A3URF_fnc_originalGetCityData;
        deleteVehicle server;
        server=[true] call A3A_fnc_createNamespace;
        private _delegated=[false] call A3A_fnc_getCityData;
        ["non_redux_delegation",_native isEqualTo _delegated,[count(_native # 0),count(_delegated # 0)]] call _check;
        deleteVehicle server;
        diag_log format ["[REDUX_POPULATION] %1",["complete",_checks,_failures]];
    };
    private _configured=getArray ((call A3A_fnc_getMapInfo) >> "population");
    {
        private _cfg=configFile >> "CfgWorlds" >> worldName >> "Names" >> (_x # 0);
        diag_log format ["[REDUX_POPULATION] %1",["configured",_x,isClass _cfg,getText(_cfg >> "name")]];
    } forEach _configured;
    diag_log "[REDUX_POPULATION] call_begin_1";
    private _first=[false] call A3A_fnc_getCityData;
    private _rows1=createHashMapFromArray (_first # 1);
    {
        private _cfg=configFile >> "CfgWorlds" >> worldName >> "Names" >> (_x # 0);
        private _name=getText(_cfg >> "name");
        private _row=_rows1 getOrDefault [_name,[-1]];
        [format ["call_1_%1",_x # 0],(_row # 0) isEqualTo (_x # 1),[_name,_row # 0,_x # 1]] call _check;
    } forEach _configured;
    diag_log "[REDUX_POPULATION] call_begin_2";
    private _second=[false] call A3A_fnc_getCityData;
    private _rows2=createHashMapFromArray (_second # 1);
    {
        private _cfg=configFile >> "CfgWorlds" >> worldName >> "Names" >> (_x # 0);
        private _name=getText(_cfg >> "name");
        private _row=_rows2 getOrDefault [_name,[-1]];
        [format ["call_2_%1",_x # 0],(_row # 0) isEqualTo (_x # 1),[_name,_row # 0,_x # 1]] call _check;
    } forEach _configured;
    diag_log "[REDUX_POPULATION] call_begin_3";
    private _third=[false] call A3A_fnc_getCityData;
    private _rows3=createHashMapFromArray (_third # 1);
    {
        private _cfg=configFile >> "CfgWorlds" >> worldName >> "Names" >> (_x # 0);
        private _name=getText(_cfg >> "name");
        private _row=_rows3 getOrDefault [_name,[-1]];
        [format ["call_3_%1",_x # 0],(_row # 0) isEqualTo (_x # 1),[_name,_row # 0,_x # 1]] call _check;
    } forEach _configured;
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
