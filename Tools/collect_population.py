"""Collect a population probe without allowing assertion-only acceptance."""
import argparse
import hashlib
import json
import re
from pathlib import Path


def collect(path):
    raw = Path(path).read_bytes()
    lines = raw.decode('utf-8-sig', errors='replace').splitlines()
    records = []
    malformed = []
    errors = []
    for line in lines:
        if re.search(r'\| Error \||Error in expression|Error position:|Error Undefined|Error Missing|Error Generic', line):
            errors.append(line)
        marker = '[REDUX_POPULATION] '
        if marker not in line:
            continue
        payload = line.split(marker, 1)[1]
        if not payload.startswith('['):
            continue
        if payload.endswith('"'):
            payload = payload[:-1].replace('""', '"')
        try:
            records.append(json.loads(payload))
        except (ValueError, TypeError):
            malformed.append(line)
    checks = [r for r in records if r and r[0] == 'check']
    completed = [r for r in records if r and r[0] == 'complete']
    names = [r[1] for r in checks]
    failures = [r[1] for r in checks if r[2] is not True]
    expected = {'independent_of_infection', 'native_population_count',
                'native_capital_population', 'second_initialization_stable',
                'third_initialization_stable', 'native_server_rows_restored'}
    configured = [r[1][0] for r in records if r and r[0] == 'configured']
    expected.update(f'call_{i}_{key}' for i in (1, 2, 3) for key in configured)
    valid = (len(configured) == 49 and len(set(configured)) == 49
             and set(names) == expected and len(names) == len(set(names))
             and completed == [['complete', len(checks), failures]])
    starts = [r for r in records if r and r[0] == 'start']
    if len(starts) == 1 and starts[0][1].lower() == 'altis':
        valid = (set(names) == {'independent_of_infection', 'non_redux_delegation'}
                 and len(names) == 2 and starts[0][2] is True
                 and completed == [['complete', len(checks), failures]])
    else:
        valid = valid and len(starts) == 1 and starts[0][1].lower() == 'chernarusredux'
    return {'sha256': hashlib.sha256(raw).hexdigest(), 'checks': checks,
            'completion': completed, 'failed_checks': failures,
            'malformed_records': malformed, 'errors': errors,
            'schema_valid': valid,
            'accepted': valid and not failures and not errors and not malformed}


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('rpt')
    p.add_argument('output')
    args = p.parse_args()
    result = collect(args.rpt)
    Path(args.output).write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({k: result[k] for k in ('sha256', 'schema_valid', 'accepted')}))
