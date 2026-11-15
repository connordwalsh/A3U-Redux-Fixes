"""Compare native High Command startup with and without a synchronized leader."""
import argparse
import hashlib
import json
from pathlib import Path
import re


def collect(path, leader):
    raw = Path(path).read_bytes()
    records, errors, malformed = [], [], []
    complete = 0
    for line in raw.decode('utf-8-sig', errors='replace').splitlines():
        if re.search(r'\bError(?::|\s+(?:in expression|Undefined|Missing|Generic|Type))|\| Error \|', line, re.IGNORECASE):
            errors.append(line)
        if '[REDUX_HC] ' not in line:
            continue
        payload = line.split('[REDUX_HC] ', 1)[1]
        if payload.rstrip('"') == 'complete':
            complete += 1
            continue
        if payload.endswith('"'):
            payload = payload[:-1].replace('""', '"')
        try:
            records.append(json.loads(payload))
        except ValueError:
            malformed.append(line)
    types = ['HighCommandSubordinate'] + (['I_G_Soldier_TL_F'] if leader else [])
    checks = {
        'one_complete_run': complete == 1 and len(records) == 3 and not malformed,
        'dedicated_no_players': bool(records) and records[0][:4] == ['start', leader, True, 0],
        'synchronization': len(records) > 1 and records[1] == ['synchronized', types],
        'scope_binding': len(records) > 2 and records[2] == ['result', leader, True, leader, types, False, 0],
        'expected_diagnostics': not errors if leader else (
            len(errors) == 2 and 'Error in expression' in errors[0]
            and 'Error Undefined variable in expression: _leader' in errors[1]),
    }
    return {'accepted': all(checks.values()), 'scope': 'Native module diagnostic, not campaign acceptance',
            'leader_present': leader, 'sha256': hashlib.sha256(raw).hexdigest(),
            'checks': checks, 'records': records, 'errors': errors, 'malformed': malformed}


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('rpt')
    parser.add_argument('output')
    parser.add_argument('--leader', action='store_true')
    args = parser.parse_args()
    result = collect(args.rpt, args.leader)
    Path(args.output).write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(result))
    raise SystemExit(0 if result['accepted'] else 1)
