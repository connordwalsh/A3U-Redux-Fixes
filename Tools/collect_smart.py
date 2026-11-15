"""Require exact native SmartMarker diagnostics; not a campaign error exemption."""
import argparse
import hashlib
import json
from pathlib import Path
import re


def collect(path, logging, fixed=False, altis=False, calls=False):
    raw = Path(path).read_bytes()
    records, errors, malformed = [], [], []
    complete = 0
    for line in raw.decode('utf-8-sig', errors='replace').splitlines():
        if re.search(r'\bError(?::|\s+(?:in expression|Undefined|Missing|Generic|Type))|\| Error \|', line, re.IGNORECASE):
            errors.append(line)
        tag = '[REDUX_SMART_CALL] ' if calls else '[REDUX_SMART] '
        if tag not in line:
            continue
        payload = line.split(tag, 1)[1]
        if payload.rstrip('"') == 'complete':
            complete += 1
            continue
        if payload.endswith('"'):
            payload = payload[:-1].replace('""', '"')
        try:
            records.append(json.loads(payload))
        except ValueError:
            malformed.append(line)
    expected_error = calls or (logging and (not fixed or altis))
    expected_records = [['uninitialized_request', True, True]] if calls else [['state', int(logging), True, 0, True, False]]
    checks = {
        'one_complete_run': complete == 1 and len(records) == 1 and not malformed,
        'native_state': records == expected_records,
        'expected_diagnostics': (len(errors) == 1 and
            'Error: SmartMarker system has not been yet initialized.' in errors[0]) if expected_error else not errors,
    }
    return {'accepted': all(checks.values()), 'scope': 'Native logging diagnostic, not campaign acceptance',
            'logging_enabled': logging, 'fixed': fixed, 'altis': altis, 'calls': calls, 'sha256': hashlib.sha256(raw).hexdigest(),
            'checks': checks, 'records': records, 'errors': errors, 'malformed': malformed}


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('rpt')
    parser.add_argument('output')
    parser.add_argument('--logging', action='store_true')
    parser.add_argument('--fixed', action='store_true')
    parser.add_argument('--altis', action='store_true')
    parser.add_argument('--calls', action='store_true')
    args = parser.parse_args()
    result = collect(args.rpt, args.logging, args.fixed, args.altis, args.calls)
    Path(args.output).write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(result))
    raise SystemExit(0 if result['accepted'] else 1)
