if (!isServer) exitWith {};
[] spawn {
 sleep 3;
 diag_log format ["[REDUX_CRATE_RUNTIME] %1",["dependencies",
  isClass (configFile >> "CfgPatches" >> "A3_Characters_F"),
  unitAddons "I_G_Soldier_TL_F",unitAddons "B_Soldier_F",unitAddons "IG_supplyCrate_F"]];
 private _crate=createVehicle ["IG_supplyCrate_F",[381.93536,4843.8149,0],[],0,"NONE"];
 diag_log format ["[REDUX_CRATE_RUNTIME] %1",["stock",typeOf _crate,netId _crate,
  everyContainer _crate apply {[_x select 0,netId (_x select 1)]},getBackpackCargo _crate]];
 [_crate,""] call BIS_fnc_initAmmoBox;
 sleep 3;
 diag_log format ["[REDUX_CRATE_RUNTIME] %1",["emptied",everyContainer _crate,getBackpackCargo _crate]];
 diag_log "[REDUX_CRATE_RUNTIME] complete";
};
