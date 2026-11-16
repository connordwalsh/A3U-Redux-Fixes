if (!isServer) exitWith {};
[] spawn {
    sleep 3;
    private _check = {
        params ["_name","_passed"];
        diag_log format ["[REDUX_CRATE_GUARDS] %1",[_name,_passed]];
    };
    // Same class/location/empty request at time zero, but not the official mission.
    ["other_mission_not_deferred",isNil {boxX getVariable "A3URF_hqCargoScheduled"}] call _check;
    ["other_mission_empty",count everyContainer boxX==0 && {getBackpackCargo boxX isEqualTo [[],[]]}] call _check;
    private _crate=createVehicle ["IG_supplyCrate_F",[381.93536,4843.8149,0],[],0,"NONE"];
    ["getter_native",(_crate call BIS_fnc_initAmmoBox) isEqualTo (_crate call A3URF_fnc_originalInitAmmoBox)] call _check;
    private _data=[[[["arifle_MX_F"],[1]],[["30Rnd_65x39_caseless_mag"],[2]],[["FirstAidKit"],[3]],[["B_AssaultPack_blk"],[1]]],false];
    [_crate,_data] call BIS_fnc_initAmmoBox;
    ["custom_cargo_retained",getWeaponCargo _crate isEqualTo [["arifle_MX_F"],[1]]
        && {getMagazineCargo _crate isEqualTo [["30Rnd_65x39_caseless_mag"],[2]]}
        && {getItemCargo _crate isEqualTo [["FirstAidKit"],[3]]}
        && {getBackpackCargo _crate isEqualTo [["B_AssaultPack_blk"],[1]]}] call _check;
    [_crate,str [[[[],[]],[[],[]],[[],[]],[[],[]]],false]] call BIS_fnc_initAmmoBox;
    ["string_cargo_native",count everyContainer _crate==0 && {getWeaponCargo _crate isEqualTo [[],[]]}] call _check;
    ["runtime_not_deferred",isNil {_crate getVariable "A3URF_hqCargoScheduled"}] call _check;
    deleteVehicle _crate;
    diag_log "[REDUX_CRATE_GUARDS] complete";
};
