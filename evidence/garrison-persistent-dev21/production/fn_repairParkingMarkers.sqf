// Pinned Ultimate 12.4.2 Redux marker data. Preserve edited missions and other maps.
if (!isServer || {toLower worldName != "chernarusredux"}) exitWith {[]};
private _changed=[];
{
    _x params ["_name","_position","_size","_direction"];
    if (!(_name in allMapMarkers) || {markerShape _name != "RECTANGLE"}) then {continue};
    private _actualSize=markerSize _name;
    private _angleError=abs (((markerDir _name-_direction+540)%360)-180);
    if ((markerPos _name) distance2D _position > 0.05
        || {abs ((_actualSize # 0)-(_size # 0))>0.005}
        || {abs ((_actualSize # 1)-(_size # 1))>0.005}
        || {_angleError>0.01}) then {continue};
    private _target=_name;
    if (_name=="reso_13_vehicle_1") then {
        // The original refers to an absent resource_13 but is inside resource_10.
        // Never replace an existing destination or repoint a custom resource_13.
        if (!("resource_10" in allMapMarkers) || {"resource_13" in allMapMarkers}
            || {"reso_10_vehicle_1" in allMapMarkers}
            || {!((markerPos _name) inArea "resource_10")}) then {continue};
        _target=createMarker ["reso_10_vehicle_1",markerPos _name];
        _target setMarkerShape (markerShape _name);
        _target setMarkerType (markerType _name);
        _target setMarkerColor (markerColor _name);
        _target setMarkerBrush (markerBrush _name);
        _target setMarkerAlpha (markerAlpha _name);
        _target setMarkerText (markerText _name);
        deleteMarker _name;
    };
    // Swap axes and turn one quarter revolution: identical corners, one valid slot.
    _target setMarkerSize [_size # 1,_size # 0];
    _target setMarkerDir ((_direction+90)%360);
    _changed pushBack _target;
} forEach [
    ["outp_6_vehicle",[3703.4519,5992.1382],[7.0570002,3.4920001],314.95398],
    ["reso_1_vehicle_1",[3577.147,6988.8281],[12.845,4.0050001],137.50999],
    ["reso_2_vehicle_1",[1626.899,7785.7969],[12.845,4.0050001],219.07497],
    ["reso_3_vehicle_1",[8623.0576,3928.521],[12.845,4.0050001],146.43401],
    ["reso_7_vehicle_1",[11811.78,12412.288],[12.845,4.0050001],200.86195],
    ["reso_13_vehicle_1",[10443.257,7769.7598],[12.845,4.0050001],139.877]
];
_changed
