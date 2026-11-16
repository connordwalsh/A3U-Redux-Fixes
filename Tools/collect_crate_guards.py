"""Verify crate delegation checks; preserve Altis's known native diagnostic."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re

EXPECTED={'other_mission_not_deferred','other_mission_empty','getter_native',
          'custom_cargo_retained','string_cargo_native','runtime_not_deferred'}

def collect(path,altis=False):
    raw=Path(path).read_bytes();rows=[];malformed=[];errors=[];complete=0
    for line in raw.decode('utf-8-sig',errors='replace').splitlines():
        if re.search(r'\bError(?::|\s+(?:in expression|Undefined|Missing|Generic|Type))|\| Error \|',line,re.I):
            errors.append(line)
        if '[REDUX_CRATE_GUARDS] ' not in line:continue
        payload=line.split('[REDUX_CRATE_GUARDS] ',1)[1]
        if payload.rstrip('"')=='complete':complete+=1;continue
        if payload.endswith('"'):payload=payload[:-1].replace('""','"')
        try:
            row=json.loads(payload)
            if not isinstance(row,list) or len(row)!=2 or not isinstance(row[0],str) or type(row[1]) is not bool:
                raise ValueError('Invalid check')
            rows.append(row)
        except (ValueError,TypeError):malformed.append(line)
    expected_errors=len(errors)==1 and 'Error: SmartMarker system has not been yet initialized.' in errors[0] if altis else not errors
    accepted=complete==1 and not malformed and Counter(r[0] for r in rows)==Counter(EXPECTED) and all(r[1] for r in rows) and expected_errors
    return {'accepted':bool(accepted),'altis':altis,'scope':'Native crate delegation only; no campaign or player acceptance',
            'sha256':hashlib.sha256(raw).hexdigest(),'checks':rows,'errors':errors,'malformed':malformed,'complete_count':complete}

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('log');parser.add_argument('output');parser.add_argument('--altis',action='store_true');args=parser.parse_args()
    report=collect(args.log,args.altis);Path(args.output).write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({'accepted':report['accepted'],'checks':len(report['checks']),'errors':len(report['errors'])}))
    raise SystemExit(0 if report['accepted'] else 1)
