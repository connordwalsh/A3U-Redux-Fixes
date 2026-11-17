// Curator may repeat activation after mission time starts. If every requested
// patch is already active, no activation is needed. Preserve native handling
// for early calls, other worlds/clients, malformed inputs and new requests.
if (isServer && {toLower worldName == "chernarusredux"} && {time>0} && {_this isEqualType []}) then {
    private _active=activatedAddons;
    private _lookup=createHashMapFromArray (_active apply {[toLower _x,true]});
    private _requiresActivation=_this findIf {
        !(_x isEqualType "") || {!(_lookup getOrDefault [toLower _x,false])}
    };
    if (_requiresActivation == -1) then {_active} else {_this call A3URF_fnc_originalActivateAddons};
} else {
    _this call A3URF_fnc_originalActivateAddons
};
