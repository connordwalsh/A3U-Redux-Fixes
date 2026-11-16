"""Strict native garrison concurrency evidence, retaining engine errors."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re

EXPECTED = {'independent_of_infection', 'occupied_mutex_waits',
            'released_mutex_completes', 'foreign_owner_unchanged',
            'array_append', 'object_created', 'object_role_added', 'object_role_roundtrip', 'mutex_released'}
EXPECTED |= {f'concurrent_{mode}_{i}' for mode in ('add', 'remove') for i in range(10)}

def collect(path, fixed):
    raw = Path(path).read_bytes()
    starts, finishes, records, errors, malformed = [], [], [], [], []
    for line in raw.decode('utf-8-sig', errors='replace').splitlines():
        if re.search(r'\bError(?::|\s+(?:in expression|Undefined|Missing|Generic|Type))|\| Error \|', line, re.I):
            errors.append(line)
        if '[REDUX_GARRISON] ' not in line:
            continue
        payload = line.split('[REDUX_GARRISON] ', 1)[1]
        if payload.endswith('"'):
            payload = payload[:-1].replace('""', '"')
        try:
            row = json.loads(payload)
            if len(row) == 3 and row[0] == 'start' and isinstance(row[1], str) and type(row[2]) is bool:
                starts.append(row)
            elif len(row) == 3 and row[0] == 'complete' and type(row[1]) is int and isinstance(row[2], list):
                finishes.append(row)
            elif len(row) == 4 and row[0] == 'check' and isinstance(row[1], str) and type(row[2]) is bool and isinstance(row[3], list):
                records.append(row)
            else:
                raise ValueError('Unexpected record')
        except (ValueError, TypeError, IndexError):
            malformed.append(line)
    failed = [r[1] for r in records if not r[2]]
    checks = {'one_run': len(starts) == len(finishes) == 1,
              'expected_environment': starts == [['start', 'chernarusredux', fixed]],
              'schema': not malformed,
              'checks_once': Counter(r[1] for r in records) == Counter(EXPECTED),
              'checks_pass': not failed, 'no_errors': not errors,
              'completion_matches': finishes == [['complete', len(records), failed]]}
    return {'accepted': all(checks.values()), 'sha256': hashlib.sha256(raw).hexdigest(),
            'scope': 'Native isolated garrison concurrency without Infection; not full campaign or multiplayer acceptance',
            'validation': checks, 'records': records, 'failed': failed, 'errors': errors, 'malformed': malformed}

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('rpt'); parser.add_argument('output')
    parser.add_argument('--baseline', action='store_true')
    args = parser.parse_args()
    result = collect(args.rpt, not args.baseline)
    Path(args.output).write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({'accepted': result['accepted'], 'checks': len(result['records']),
                      'failed': result['failed'], 'errors': len(result['errors'])}))
    raise SystemExit(0 if result['accepted'] else 1)
