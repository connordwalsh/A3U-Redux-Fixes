if (!isServer) exitWith {};
[] spawn {
    sleep 3;
    diag_log "[REDUX_NEGATIVE] start";
    server=[true] call A3A_fnc_createNamespace;sidesX=[true] call A3A_fnc_createNamespace;
    teamPlayer=independent;seaports=[];resourcesX=[];A3U_blackMarketDiscountVehicle=0;
    A3U_blackMarketStock=createHashMapFromArray [["test",createHashMapFromArray [["O_Heli_Light_02_dynamicLoadout_F",28800]]]];
    private _unknown=["O_Truck_03_transport_F"] call A3A_fnc_vehiclePrice;
    diag_log format ["[REDUX_NEGATIVE] %1",["unknown_price",_unknown==1000,_unknown]];
    A3U_blackMarketDiscountVehicle=10;
    private _zero=["O_Heli_Light_02_dynamicLoadout_F"] call A3A_fnc_vehiclePrice;
    diag_log format ["[REDUX_NEGATIVE] %1",["zero_discounted_price",_zero==1000,_zero]];
    deleteVehicle server;deleteVehicle sidesX;
    diag_log "[REDUX_NEGATIVE] complete";
};
