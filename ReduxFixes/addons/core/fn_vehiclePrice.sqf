// Loot crates are utility items priced by a campaign setting, not vehicle stock.
// Native saveLoop still calls vehiclePrice for their save-time reimbursement.
params ["_typeX"];
if (toLower worldName == "chernarusredux" && {!isNil "A3A_faction_reb"}
    && {!isNil "lootCratePrice"}
    && {_typeX == (A3A_faction_reb getOrDefault ["lootCrate",""])}
    && {lootCratePrice isEqualType 0} && {finite lootCratePrice}
    && {lootCratePrice >= 0}) exitWith {lootCratePrice};
// A missing HQ entry is legitimate for black-market-only vehicles. Native
// vehiclePrice logs an error before returning this same positive fallback.
private _fallback=-1;
if (toLower worldName=="chernarusredux" && {!isNil "server"}
    && {isNil {server getVariable _typeX}} && {!isNil "A3U_blackMarketStock"}
    && {A3U_blackMarketStock isEqualType createHashMap}) then {
    private _categories=values A3U_blackMarketStock;
    if ((_categories findIf {!(_x isEqualType createHashMap)})==-1) then {
        private _stock=createHashMap;
        {_stock merge _x} forEach _categories;
        private _base=_stock getOrDefault [_typeX,0];
        if (_base isEqualType 0 && {finite _base} && {_base>0}) then {
            _fallback=_this call A3U_fnc_blackMarketVehiclePrice;
        };
    };
};
if (_fallback isEqualType 0 && {finite _fallback} && {_fallback>0}) exitWith {_fallback};
// Missing/invalid prices still follow native diagnostics and the 1000 fallback.
_this call A3URF_fnc_originalVehiclePrice
