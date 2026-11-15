"""Evaluate exact marker coverage and short empty-vehicle terrain probes."""
import argparse
from collections import Counter
import hashlib
import json
import math
from pathlib import Path
import re


def collect(path, source):
    raw = Path(path).read_bytes()
    records, errors, malformed = [], [], []
    completed = 0
    for line in raw.decode('utf-8-sig', errors='replace').splitlines():
        if re.search(r'Error(?::|\s+(?:in expression|Undefined|Missing|Generic|Type))|\| Error \|', line):
            errors.append(line)
        if '[REDUX_MARKERS] ' not in line:
            continue
        payload = line.split('[REDUX_MARKERS] ', 1)[1]
        if payload.rstrip('"') == 'complete':
            completed += 1
            continue
        if payload.endswith('"'):
            payload = payload[:-1].replace('""', '"')
        try:
            records.append(json.loads(payload))
        except ValueError:
            malformed.append(line)
    data = json.loads(Path(source).read_text(encoding='utf-8'))
    names = [row[0] for row in data['markers']]
    places = [row for row in records if row[0] == 'places']
    vehicles = [row for row in records if row[0] == 'vehicle']
    expected_places = Counter((n, v) for n in names for v in ('original', 'rotate90', 'rotate270'))
    expected_vehicles = Counter((n, v, c) for n in names for v in ('rotate90', 'rotate270') for c in ('C_Offroad_01_F', 'O_MRAP_02_F'))
    failures = []
    for row in vehicles:
        if not (len(row[4]) == 3 and row[5] <= 0.01 and row[6] is True
                and row[8] < 1 and row[9][2] > 0.9 and row[10] is True):
            failures.append(row)
    footprints = []
    def corners(size, angle):
        rad = math.radians(angle)
        return [(x * math.cos(rad) + y * math.sin(rad), -x * math.sin(rad) + y * math.cos(rad))
                for x in (-size[0], size[0]) for y in (-size[1], size[1])]
    for row in data['markers']:
        size, direction = row[3:5]
        original = corners(size, direction)
        error = max(min(math.dist(a, b) for b in original)
                    for delta in (90, 270) for a in corners(size[::-1], direction + delta))
        footprints.append({'marker': row[0], 'max_corner_error_metres': error,
                           'width': size[1] * 2, 'length': size[0] * 2})
    expected_errors = [line for line in errors if 'not long enough for vehicles' in line]
    checks = {
        'complete_once': completed == 1,
        'records_parse': not malformed,
        'all_places_once': Counter((r[1], r[2]) for r in places) == expected_places,
        'all_vehicles_once': Counter((r[1], r[2], r[3]) for r in vehicles) == expected_vehicles,
        'original_rejected_candidates_one_slot': all(len(r[5]) == (0 if r[2] == 'original' else 1) for r in places),
        'vehicle_checks_pass': not failures,
        'only_six_expected_dimension_errors': len(expected_errors) == len(errors) == 6,
        'unchanged_footprints_valid_dimensions': all(r['max_corner_error_metres'] < 1e-6 and r['width'] >= 6 and r['length'] >= 10 for r in footprints),
    }
    return {'scope': 'Four-second empty-vehicle probes; not connected-player or long-session acceptance',
            'sha256': hashlib.sha256(raw).hexdigest(), 'checks': checks,
            'accepted': all(checks.values()), 'failures': failures, 'errors': errors,
            'malformed': malformed, 'footprints': footprints, 'records': records}


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('rpt'); p.add_argument('source'); p.add_argument('output')
    args = p.parse_args()
    result = collect(args.rpt, args.source)
    Path(args.output).write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({'accepted': result['accepted'], 'checks': result['checks']}))
