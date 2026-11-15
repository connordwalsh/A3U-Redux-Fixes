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
    pricing = any('[REDUX_PRICING]' in line for line in lines)
    parking = any('[REDUX_PARKING]' in line for line in lines)
    malformed = []
    errors = []
    for line in lines:
        if re.search(r'\| Error \||Error(?::|\s+(?:in expression|Undefined|Missing|Generic|Type))|Error position:', line):
            errors.append(line)
        marker = '[REDUX_PARKING] ' if parking else '[REDUX_PRICING] ' if pricing else '[REDUX_POPULATION] '
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
    if parking:
        expected = {'six_markers_corrected', 'orphan_reconnected', 'appearance_preserved',
                    'idempotent', 'custom_geometry_preserved', 'existing_destination_preserved',
                    'custom_resource13_preserved', 'missing_parent_preserved'}
        expected.update('native_slot_' + site for site in ('outpost_6', 'resource_1', 'resource_2', 'resource_3', 'resource_7', 'resource_10'))
        if len(starts) == 1 and starts[0][1].lower() == 'altis':
            expected = {'other_world_unchanged'}
        valid = (set(names) == expected and len(names) == len(expected)
                 and len(starts) == 1 and starts[0][1].lower() in ('chernarusredux', 'altis')
                 and starts[0][2] is True
                 and completed == [['complete', len(checks), failures]])
    elif pricing:
        expected = {'independent_of_infection', 'faction_loot_class', 'vehicle_native_price',
                    'loot_discount_unchanged', 'vehicle_discount_native_price',
                    'rally_class_delegates', 'uninitialized_loot_setting_delegates',
                    'missing_faction_delegates'}
        expected.update(f'loot_price_{n}' for n in (100, 200, 300, 400, 500))
        valid = (set(names) == expected and len(names) == len(expected)
                 and len(starts) == 1 and starts[0][1].lower() == 'chernarusredux'
                 and completed == [['complete', len(checks), failures]])
        if len(starts) == 1 and starts[0][1].lower() == 'altis':
            valid = (set(names) == {'independent_of_infection', 'non_redux_pricing_delegates'}
                     and len(names) == 2 and starts[0][2] is True
                     and completed == [['complete', len(checks), failures]])
    elif len(starts) == 1 and starts[0][1].lower() == 'altis':
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
