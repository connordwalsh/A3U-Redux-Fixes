if (!isServer) exitWith {};
[] spawn {
    sleep 3;
    private _withLeader=getNumber(missionConfigFile >> "A3URF_leaderPresent")==1;
    diag_log format ["[REDUX_HC] %1",["start",_withLeader,isDedicated,count allPlayers,productVersion]];
    private _commander=objNull;
    private _logic=objNull;
    private _logicGroup=createGroup [sideLogic,true];
    if (_withLeader) then {
        private _group=createGroup [independent,true];
        _commander=_group createUnit ["I_G_Soldier_TL_F",[1000,1000,0],[],0,"NONE"];
        _commander disableAI "ALL";
    };
    private _marta=_logicGroup createUnit ["MartaManager",[1000,1000,0],[],0,"NONE"];
    // Complete synchronization before the engine's scheduled HC script can run.
    isNil {
        _logic=_logicGroup createUnit ["HighCommand",[1005,1000,0],[],0,"NONE"];
        private _sub=_logicGroup createUnit ["HighCommandSubordinate",[1010,1000,0],[],0,"NONE"];
        _logic synchronizeObjectsAdd [_sub];
        if (_withLeader) then {_logic synchronizeObjectsAdd [_commander]};
    };
    diag_log format ["[REDUX_HC] %1",["synchronized",(synchronizedObjects _logic) apply {typeOf _x}]];
    sleep 8;
    diag_log format ["[REDUX_HC] %1",["result",_withLeader,
        missionNamespace getVariable ["BIS_HC_mainscope",objNull]==_logic,
        !isNull _commander && {(_commander getVariable ["BIS_HC_scope",objNull])==_logic},
        (synchronizedObjects _logic) apply {typeOf _x},
        isNil "BIS_MARTA_mainScope",count allPlayers]];
    diag_log "[REDUX_HC] complete";
};
