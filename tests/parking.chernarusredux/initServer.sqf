if (!isServer) exitWith {};
[] spawn {
    sleep 3;
    private _count=0;private _failed=[];
    private _check={params ["_name","_ok",["_details",[]]];_count=_count+1;
        if (!_ok) then {_failed pushBack _name};
        diag_log format ["[REDUX_PARKING] %1",["check",_name,_ok,_details]]};
    private _rows=call compile preprocessFileLineNumbers "markerData.sqf";
    diag_log format ["[REDUX_PARKING] %1",["start",worldName,isClass(configFile >> "CfgPatches" >> "A3URF_core"),productVersion]];
    private _seed={
        {
            _x params ["_parking","_site","_pos","_size","_dir","_sitePos","_siteSize","_siteDir"];
            if (_parking=="reso_10_vehicle_1") then {_parking="reso_13_vehicle_1"};
            createMarker [_site,_sitePos];_site setMarkerShape "RECTANGLE";
            _site setMarkerSize _siteSize;_site setMarkerDir _siteDir;
            createMarker [_parking,_pos];_parking setMarkerShape "RECTANGLE";
            _parking setMarkerSize _size;_parking setMarkerDir _dir;
            _parking setMarkerColor "ColorGreen";_parking setMarkerBrush "Solid";
            _parking setMarkerAlpha 0.6;_parking setMarkerText "Preserved parking";
        } forEach _rows;
    };
    private _cleanup={
        {deleteMarker (_x # 0);deleteMarker (_x # 1)} forEach _rows;
        deleteMarker "reso_13_vehicle_1";deleteMarker "resource_13";
    };
    call _seed;
    if (toLower worldName != "chernarusredux") exitWith {
        ["other_world_unchanged",([] call A3URF_fnc_repairParkingMarkers) isEqualTo []
            && {"reso_13_vehicle_1" in allMapMarkers}
            && {abs ((markerSize "outp_6_vehicle" # 0)-7.057)<0.005}] call _check;
        call _cleanup;
        diag_log format ["[REDUX_PARKING] %1",["complete",_count,_failed]];
    };
    private _changed=[] call A3URF_fnc_repairParkingMarkers;
    ["six_markers_corrected",count _changed==6,[_changed]] call _check;
    ["orphan_reconnected",!("reso_13_vehicle_1" in allMapMarkers)
        && {"reso_10_vehicle_1" in allMapMarkers}
        && {(markerPos "reso_10_vehicle_1") inArea "resource_10"}] call _check;
    ["appearance_preserved",markerColor "reso_10_vehicle_1"=="ColorGreen"
        && {markerBrush "reso_10_vehicle_1"=="Solid"}
        && {abs(markerAlpha "reso_10_vehicle_1"-0.6)<0.001}
        && {markerText "reso_10_vehicle_1"=="Preserved parking"}] call _check;
    ["idempotent",([] call A3URF_fnc_repairParkingMarkers) isEqualTo []] call _check;
    server=[true] call A3A_fnc_createNamespace;spawner=[true] call A3A_fnc_createNamespace;
    [] call A3A_fnc_prepareMarkerArrays;
    {
        _x params ["_parking","_site","_pos","_size","_dir"];
        private _places=spawner getVariable [_site+"_vehicle_places",[]];
        private _inside=_places select {(_x # 0) inArea _parking};
        ["native_slot_"+_site,count _inside==1 && {(_inside # 0 # 0) distance2D _pos<0.1},[_inside]] call _check;
    } forEach _rows;
    deleteVehicle server;deleteVehicle spawner;call _cleanup;call _seed;
    "outp_6_vehicle" setMarkerSize [8,4];
    "reso_1_vehicle_1" setMarkerDir 10;
    "reso_2_vehicle_1" setMarkerPos ((markerPos "reso_2_vehicle_1") vectorAdd [5,0,0]);
    "reso_3_vehicle_1" setMarkerShape "ELLIPSE";
    createMarker ["reso_10_vehicle_1",[10,10,0]];
    private _guarded=[] call A3URF_fnc_repairParkingMarkers;
    ["custom_geometry_preserved",_guarded isEqualTo ["reso_7_vehicle_1"]
        && {markerSize "outp_6_vehicle" isEqualTo [8,4]}
        && {markerDir "reso_1_vehicle_1"==10}
        && {markerShape "reso_3_vehicle_1"=="ELLIPSE"}] call _check;
    ["existing_destination_preserved",markerPos "reso_10_vehicle_1" isEqualTo [10,10,0]
        && {"reso_13_vehicle_1" in allMapMarkers}] call _check;
    deleteMarker "reso_10_vehicle_1";createMarker ["resource_13",[10,10,0]];
    ["custom_resource13_preserved",([] call A3URF_fnc_repairParkingMarkers) isEqualTo []
        && {"reso_13_vehicle_1" in allMapMarkers}] call _check;
    deleteMarker "resource_13";deleteMarker "resource_10";
    ["missing_parent_preserved",([] call A3URF_fnc_repairParkingMarkers) isEqualTo []
        && {"reso_13_vehicle_1" in allMapMarkers}] call _check;
    call _cleanup;
    diag_log format ["[REDUX_PARKING] %1",["complete",_count,_failed]];
};
