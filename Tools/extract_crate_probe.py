"""Extract the pinned Redux HQ crate into paired minimal Eden fixtures."""
import hashlib
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
source=ROOT.parent/'Zombie Occupant Faction/.work/ultimate/A3A/addons/maps/Antistasi_chernarusredux.chernarusredux/mission.sqm'
digest=hashlib.sha256(source.read_bytes()).hexdigest()
assert digest=='2c4d2556a1a534488f53fb3e3498640b0a40bdb38fb10c1feaec32851e2f43b0'
text=source.read_text(encoding='utf-8-sig')


def block(text,start):
    opening=text.index('{',start);depth=0;quoted=False;i=opening
    while i<len(text):
        char=text[i]
        if char=='"':
            if quoted and i+1<len(text) and text[i+1]=='"':i+=2;continue
            quoted=not quoted
        elif not quoted:
            if char=='{':depth+=1
            if char=='}':
                depth-=1
                if depth==0:return text[start:i+2]
        i+=1
    raise ValueError('Unterminated class')


crate=block(text,text.index('\t\tclass Item7\n',text.index('class Mission')))
assert 'type="IG_supplyCrate_F";' in crate and 'name="boxX";' in crate
attribute=block(crate,crate.index('class Attribute0'))
assert 'property="ammoBox";' in attribute and 'value="";' in attribute
stock=crate.replace(attribute,'').replace('class Attribute1','class Attribute0').replace('nAttributes=2;','nAttributes=1;')
header=text[:text.index('class Mission')]
commander_start=text.rfind('\t\t\t\tclass Item0\n',0,text.index('name="commanderX";'))
commander=block(text,commander_start).replace('name="commanderX";','name="probeObserver";')
assert 'type="I_G_Soldier_TL_F";' in commander and 'class Inventory' in commander
observer='''class Item1 {
 dataType="Group";side="Independent";id=101;
 class Entities {items=1;
'''+commander+'\n};};'
code='''if (!isServer) exitWith {};
[] spawn {
 sleep 3;
 diag_log format ["[REDUX_CRATE] %1",["state",typeOf boxX,netId boxX,
  everyContainer boxX apply {[_x select 0,netId (_x select 1)]},getBackpackCargo boxX]];
 diag_log "[REDUX_CRATE] complete";
};
'''
for name,body in [('cratestock',stock),('crateempty',crate)]:
    folder=ROOT/'tests'/f'{name}.chernarusredux';folder.mkdir(exist_ok=True)
    body=body.replace('class Item7','class Item0',1)
    (folder/'mission.sqm').write_text(header+'class Mission {assetType="Free";class Intel {year=2026;month=11;day=15;hour=12;minute=0;};class Entities {items=2;\n'+body+'\n'+observer+'\n};};\n',encoding='utf-8')
    (folder/'description.ext').write_text('onLoadName="HQ crate startup diagnostic";\nrespawn=3;respawnDelay=2;disabledAI=0;briefing=0;debriefing=0;allowFunctionsLog=1;\nclass Header {gameType=Coop;minPlayers=1;maxPlayers=1;};\n',encoding='utf-8')
    (folder/'initServer.sqf').write_text(code,encoding='utf-8')
    (folder/'source.json').write_text(json.dumps({'upstream_commit':'c7c8247672ed5e7d4aa317d47efb371c41de4e7d','mission_sha256':digest,'crate_item':7,'ammo_attribute_retained':name=='crateempty'},indent=2)+'\n',encoding='utf-8')
