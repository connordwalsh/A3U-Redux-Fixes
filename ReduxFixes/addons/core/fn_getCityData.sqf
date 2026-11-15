// Ultimate 12.4.2 calls getCityData twice during startup. Its first call stores
// [population, vehicle count, support, support] under each town's display name.
// On the second call that array masks a numeric config-name population fallback.
// Repair only this stale-array case before delegating to the installed native body.
if (toLower worldName != "chernarusredux" || {isNil "server"}) exitWith {
    _this call A3URF_fnc_originalGetCityData
};
private _mapInfo=call A3A_fnc_getMapInfo;
{
    _x params ["_key","_population"];
    private _city=configFile >> "CfgWorlds" >> worldName >> "Names" >> _key;
    if (!isClass _city || {!(_population isEqualType 0)} || {!finite _population} || {_population<0}) then {continue};
    private _name=getText (_city >> "name");
    private _old=server getVariable [_name,objNull];
    if (_name!="" && {_old isEqualType []} && {count _old==4}) then {
        // Remove only the stale display-name cache. Native initialization writes
        // the configured numeric key and recreates the normal four-field array.
        server setVariable [_name,nil];
    };
} forEach getArray (_mapInfo >> "population");
_this call A3URF_fnc_originalGetCityData
