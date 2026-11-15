"""Verify early native behavior and late idempotence with required negative diagnostics."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re


def collect(path, guarded=False, altis=False):
    raw=Path(path).read_bytes();records=[];malformed=[];errors=[];start=complete=0
    for line in raw.decode('utf-8-sig',errors='replace').splitlines():
        if re.search(r'\bError(?::|\s+(?:in expression|Undefined|Missing|Generic|Type))|\| Error \|',line,re.IGNORECASE):errors.append(line)
        if '[REDUX_ACTIVATION] ' not in line:continue
        payload=line.split('[REDUX_ACTIVATION] ',1)[1]
        if payload.rstrip('"')=='start':start+=1;continue
        if payload.rstrip('"')=='complete':complete+=1;continue
        if payload.endswith('"'):payload=payload[:-1].replace('""','"')
        try:
            row=json.loads(payload)
            if not isinstance(row,list) or not row or not isinstance(row[0],str):raise ValueError('Invalid record')
            records.append(row)
        except (ValueError,TypeError):malformed.append(line)
    expected={'early_native','active_result','empty_result','unknown_rejected','wrong_type_rejected','active_set_unchanged'}
    rows={r[0]:r for r in records}
    checks={'one_run':start==complete==1,'schema':not malformed and Counter(r[0] for r in records)==Counter(expected)}
    for name in expected-{'active_result','empty_result'}:
        checks[name]=rows.get(name)==[name,True]
    for name in ['active_result','empty_result']:
        row=rows.get(name,[])
        checks[name]=len(row)==3 and (type(row[1]) is int and row[1]>0 and row[2] is True if guarded else row[1:]==[0,False])
    activation=[e for e in errors if 'The function can be activated only during the mission init.' in e]
    smart=[e for e in errors if 'Error: SmartMarker system has not been yet initialized.' in e]
    checks['native_negative_diagnostics']=len(activation)==(2 if guarded else 4) and len(smart)==(1 if altis else 0) and len(errors)==len(activation)+len(smart)
    return {'accepted':all(checks.values()),'guarded':guarded,'altis':altis,'scope':'Focused activation probe; intentional native errors required',
            'sha256':hashlib.sha256(raw).hexdigest(),'checks':checks,'records':records,'errors':errors,'malformed':malformed}


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('rpt');parser.add_argument('output');parser.add_argument('--guarded',action='store_true');parser.add_argument('--altis',action='store_true');args=parser.parse_args()
    result=collect(args.rpt,args.guarded,args.altis);Path(args.output).write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(result));raise SystemExit(0 if result['accepted'] else 1)
