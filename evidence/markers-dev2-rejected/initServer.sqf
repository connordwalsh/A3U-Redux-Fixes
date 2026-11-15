if (!isServer) exitWith {};
[] spawn {
    sleep 3;
    private _rows=call compile preprocessFileLineNumbers "markerData.sqf";
    diag_log format ["[REDUX_MARKERS] %1",["start",worldName,count _rows,productVersion]];
    {
        _x params ["_parking","_site","_position","_size","_direction","_sitePosition","_siteSize","_siteDirection"];
        createMarker [_site,_sitePosition];_site setMarkerShape "ELLIPSE";
        _site setMarkerSize _siteSize;_site setMarkerDir _siteDirection;
        createMarker [_parking,_position];_parking setMarkerShape "RECTANGLE";
        private _suffix=(_parking splitString "_") select [2];
        _suffix=_suffix joinString "_";
        {
            _x params ["_variant","_candidateSize","_candidateDirection"];
            _parking setMarkerSize _candidateSize;_parking setMarkerDir _candidateDirection;
            spawner=[true] call A3A_fnc_createNamespace;
            [_site,[_suffix]] call A3A_fnc_initSpawnPlaces;
            private _places=spawner getVariable [_site+"_vehicle_places",[]];
            private _inside=_places select {(_x # 0) inArea _parking};
            diag_log format ["[REDUX_MARKERS] %1",["places",_parking,_variant,_candidateSize,_candidateDirection,_inside]];
            if (_variant!="original") then {
                {
                    _x params ["_pos","_dir"];
                    private _near=(nearestTerrainObjects [_pos,["HOUSE","BUILDING","WALL","ROCK"],8,false,true]) select [0,8];
                    diag_log format ["[REDUX_MARKERS] %1",["terrain",_parking,_variant,_pos,surfaceNormal _pos,
                        _near apply {[typeOf _x,getPosATL _x]}]];
                    {
                        private _class=_x;
                        private _empty=_pos findEmptyPosition [0,0,_class];
                        private _vehicle=createVehicle [_class,_pos,[],0,"CAN_COLLIDE"];
                        _vehicle setDir _dir;_vehicle setPosATL _pos;
                        sleep 4;
                        diag_log format ["[REDUX_MARKERS] %1",["vehicle",_parking,_variant,_class,
                            _empty,damage _vehicle,alive _vehicle,getPosATL _vehicle,_vehicle distance2D _pos,
                            vectorUp _vehicle,canMove _vehicle]];
                        deleteVehicle _vehicle;
                    } forEach ["C_Offroad_01_F","O_MRAP_02_F"];
                } forEach _inside;
            };
            deleteVehicle spawner;
        } forEach [["original",_size,_direction],["rotate90",[_size # 1,_size # 0],(_direction+90)%360],
            ["rotate270",[_size # 1,_size # 0],(_direction+270)%360]];
        deleteMarker _parking;deleteMarker _site;
    } forEach _rows;
    diag_log "[REDUX_MARKERS] complete";
};
