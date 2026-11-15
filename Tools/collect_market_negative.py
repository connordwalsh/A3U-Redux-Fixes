"""Negative control: require native error messages as well as fallback values."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re

def collect(path):
    raw=Path(path).read_bytes(); records=[];errors=[];malformed=[];start=0;complete=0
    for line in raw.decode('utf-8-sig',errors='replace').splitlines():
        if re.search(r'Error(?::|\s+(?:in expression|Undefined|Missing|Generic|Type))|\| Error \|',line): errors.append(line)
        if '[REDUX_NEGATIVE] ' not in line: continue
        payload=line.split('[REDUX_NEGATIVE] ',1)[1]
        if payload.rstrip('"')=='start':start+=1;continue
        if payload.rstrip('"')=='complete':complete+=1;continue
        if payload.endswith('"'):payload=payload[:-1].replace('""','"')
        try:records.append(json.loads(payload))
        except ValueError:malformed.append(line)
    expected=Counter({
        'Invalid vehicle price :O_Truck_03_transport_F.':1,
        'Invalid vehicle price at O_Truck_03_transport_F.':1,
        'Invalid vehicle price :O_Heli_Light_02_dynamicLoadout_F.':1,
        '0 was an invalid price. Defaulting to 1000':2})
    actual=Counter()
    unexpected=[]
    for line in errors:
        matches=[text for text in expected if text in line]
        if len(matches)==1:actual[matches[0]]+=1
        else:unexpected.append(line)
    checks={'one_run':start==complete==1,'valid_records':not malformed,
            'fallback_values':records==[['unknown_price',True,1000],['zero_discounted_price',True,1000]],
            'native_diagnostics_retained':actual==expected and not unexpected}
    return {'scope':'Intentional invalid-price negative control; five native errors REQUIRED',
            'sha256':hashlib.sha256(raw).hexdigest(),'accepted':all(checks.values()),
            'checks':checks,'records':records,'errors':errors,'unexpected_errors':unexpected,'malformed':malformed}

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('rpt');p.add_argument('output');a=p.parse_args()
    r=collect(a.rpt);Path(a.output).write_text(json.dumps(r,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'accepted':r['accepted'],'checks':r['checks']}))
