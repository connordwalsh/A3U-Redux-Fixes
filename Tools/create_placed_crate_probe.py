"""Build paired version-12 startup probes; not a reproduction of Eden loading."""
from pathlib import Path

root=Path(__file__).resolve().parents[1]
base=(root/'tests/hcleader.chernarusredux/mission.sqm').read_text()
assert base.count('    class Groups')==1
for variant in ['Stock','Empty']:
    folder=root/'tests'/f'crateplaced{variant.lower()}.chernarusredux'
    folder.mkdir(exist_ok=True)
    init='diag_log format ["[REDUX_CRATE_PLACED] %1",["before",netId this,everyContainer this apply {[_x select 0,netId (_x select 1)]}]];'
    if variant=='Empty':
        init+='[this,""] call BIS_fnc_initAmmoBox;'
    vehicles='''    class Vehicles {
        items=1;class Item0 {
            position[]={381.93536,61.21471,4843.8149};
            id=7;side="EMPTY";vehicle="IG_supplyCrate_F";
            skill=0.6;text="boxX";
            init="'''+init.replace('"','""')+'''";
        };
    };
'''
    mission=base.replace('    class Groups',vehicles+'    class Groups')
    mission=mission.replace('{"A3_Characters_F"}', '{"A3_Characters_F","A3_Weapons_F_Ammoboxes"}')
    (folder/'mission.sqm').write_text(mission,encoding='utf-8')
    (folder/'description.ext').write_text('respawn=3;respawnDelay=2;disabledAI=0;briefing=0;debriefing=0;allowFunctionsLog=1;\nclass Header {gameType=Coop;minPlayers=1;maxPlayers=1;};\n',encoding='utf-8')
    (folder/'initServer.sqf').write_text('''if (!isServer) exitWith {};
[] spawn {
 sleep 3;
 diag_log format ["[REDUX_CRATE_PLACED] %1",["after",typeOf boxX,netId boxX,
  everyContainer boxX apply {[_x select 0,netId (_x select 1)]},getBackpackCargo boxX]];
 diag_log "[REDUX_CRATE_PLACED] complete";
};
''',encoding='utf-8')
