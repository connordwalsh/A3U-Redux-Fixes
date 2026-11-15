// Loot crates are utility items priced by a campaign setting, not vehicle stock.
// Native saveLoop still calls vehiclePrice for their save-time reimbursement.
params ["_typeX"];
if (toLower worldName == "chernarusredux" && {!isNil "A3A_faction_reb"}
    && {!isNil "lootCratePrice"}
    && {_typeX == (A3A_faction_reb getOrDefault ["lootCrate",""])}
    && {lootCratePrice isEqualType 0} && {finite lootCratePrice}
    && {lootCratePrice >= 0}) exitWith {lootCratePrice};
_this call A3URF_fnc_originalVehiclePrice
