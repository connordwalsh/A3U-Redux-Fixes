if (!isServer) exitWith {};
[] spawn {
    private _checks=0;private _failures=[];
    private _check={params ["_name","_passed",["_detail",[]]];
        _checks=_checks+1;if (!_passed) then {_failures pushBack _name};
        diag_log format ["[REDUX_MARKET] %1",["check",_name,_passed,_detail]]};
    sleep 3;
    diag_log format ["[REDUX_MARKET] %1",["start",worldName,isClass(configFile >> "CfgPatches" >> "A3URF_core"),productVersion]];
    ["independent_of_infection",!isClass(configFile >> "CfgPatches" >> "A3I_core")
        && {!isClass(configFile >> "CfgPatches" >> "WBK_ZombieCreatures")}] call _check;
    server=[true] call A3A_fnc_createNamespace;
    sidesX=[true] call A3A_fnc_createNamespace;
    teamPlayer=independent; seaports=[];resourcesX=[];A3U_blackMarketDiscountVehicle=0;
    A3U_blackMarketStock=createHashMapFromArray [["test",createHashMapFromArray [["B_Quadbike_01_F",800],["Land_TentA_F",20]]]];
    (A3U_blackMarketStock get "test") set ["O_Heli_Light_02_dynamicLoadout_F",28800];
    server setVariable ["B_Quadbike_01_F",1000];server setVariable ["Land_TentA_F",30];
    A3A_faction_reb=createHashMapFromArray [["lootCrate","A3AP_Box_Syndicate_Ammo_F"],["rallyPoint","Land_TentA_F"]];
    if (toLower worldName != "chernarusredux") exitWith {
        lootCratePrice=100;
        server setVariable ["A3AP_Box_Syndicate_Ammo_F",600];
        (A3U_blackMarketStock get "test") set ["A3AP_Box_Syndicate_Ammo_F",500];
        ["non_redux_pricing_delegates",(["A3AP_Box_Syndicate_Ammo_F"] call A3A_fnc_vehiclePrice)==500] call _check;
        deleteVehicle server;deleteVehicle sidesX;
        diag_log format ["[REDUX_MARKET] %1",["complete",_checks,_failures]];
    };
    {
        lootCratePrice=_x;
        private _actual=["A3AP_Box_Syndicate_Ammo_F"] call A3A_fnc_vehiclePrice;
        [format ["loot_price_%1",_x],_actual==_x,[_actual,_x]] call _check;
    } forEach [100,200,300,400,500];
    A3A_faction_reb set ["lootCrate","Box_NATO_Ammo_F"];
    ["faction_loot_class",(["Box_NATO_Ammo_F"] call A3A_fnc_vehiclePrice)==500] call _check;
    ["vehicle_native_price",(["B_Quadbike_01_F"] call A3A_fnc_vehiclePrice)==800] call _check;
    ["black_market_only_price",(["O_Heli_Light_02_dynamicLoadout_F"] call A3A_fnc_vehiclePrice)==28800] call _check;
    seaports=["testPort"];resourcesX=["testResource"];
    sidesX setVariable ["testPort",teamPlayer];sidesX setVariable ["testResource",teamPlayer];
    A3U_blackMarketDiscountVehicle=2;
    ["loot_discount_unchanged",(["Box_NATO_Ammo_F"] call A3A_fnc_vehiclePrice)==500] call _check;
    ["vehicle_discount_native_price",(["B_Quadbike_01_F"] call A3A_fnc_vehiclePrice)==571] call _check;
    ["rally_class_delegates",(["Land_TentA_F"] call A3A_fnc_vehiclePrice)==14] call _check;
    ["black_market_only_discount",(["O_Heli_Light_02_dynamicLoadout_F"] call A3A_fnc_vehiclePrice)==20571] call _check;
    lootCratePrice=nil;
    ["uninitialized_loot_setting_delegates",(["B_Quadbike_01_F"] call A3A_fnc_vehiclePrice)==571] call _check;
    A3A_faction_reb=nil;
    ["missing_faction_delegates",(["B_Quadbike_01_F"] call A3A_fnc_vehiclePrice)==571] call _check;
    deleteVehicle server;deleteVehicle sidesX;
    diag_log format ["[REDUX_MARKET] %1",["complete",_checks,_failures]];
};
