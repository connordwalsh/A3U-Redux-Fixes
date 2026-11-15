"""Require every deferred-HC assertion and reject all engine error records."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re

EXPECTED = {'empty_waits', 'duplicate_uses_worker', 'late_leader_bound',
            'native_completed', 'one_marta', 'main_scope_preserved',
            'second_empty_waits', 'deleted_scope_stops_worker'}


def collect(path):
    raw = Path(path).read_bytes()
    records, errors, malformed = [], [], []
    start = complete = 0
    for line in raw.decode('utf-8-sig', errors='replace').splitlines():
        if re.search(r'\bError(?::|\s+(?:in expression|Undefined|Missing|Generic|Type))|\| Error \|', line, re.IGNORECASE):
            errors.append(line)
        if '[REDUX_HC_DELAY] ' not in line:
            continue
        payload = line.split('[REDUX_HC_DELAY] ', 1)[1]
        if payload.rstrip('"') == 'start':
            start += 1
            continue
        if payload.rstrip('"') == 'complete':
            complete += 1
            continue
        if payload.endswith('"'):
            payload = payload[:-1].replace('""', '"')
        try:
            record = json.loads(payload)
            if not isinstance(record, list) or len(record) != 2 or not isinstance(record[0], str) or type(record[1]) is not bool:
                raise ValueError('Invalid assertion')
            records.append(record)
        except ValueError:
            malformed.append(line)
    checks = {'one_run': start == complete == 1, 'schema_valid': not malformed,
              'all_checks_once': Counter(r[0] for r in records) == Counter(EXPECTED),
              'checks_pass': all(r[1] for r in records), 'no_errors': not errors}
    return {'accepted': all(checks.values()), 'scope': 'Isolated deferred native HC lifecycle; no client UI acceptance',
            'sha256': hashlib.sha256(raw).hexdigest(), 'checks': checks,
            'records': records, 'errors': errors, 'malformed': malformed}


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('rpt')
    parser.add_argument('output')
    args = parser.parse_args()
    result = collect(args.rpt)
    Path(args.output).write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(result))
    raise SystemExit(0 if result['accepted'] else 1)
