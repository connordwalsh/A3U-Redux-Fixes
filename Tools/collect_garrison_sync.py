"""Verify native reset/live/JIP evidence from a server and two distinct clients."""
import argparse
import hashlib
import json
from pathlib import Path
import re


def collect(server, first, second):
    sources = []
    errors = []
    malformed = []
    streams = []
    for path, tag in ((server, 'GARRISON_SYNC'), (first, 'GARRISON_SYNC_CLIENT'),
                      (second, 'GARRISON_SYNC_CLIENT')):
        raw = Path(path).read_bytes()
        sources.append({'file': Path(path).name, 'sha256': hashlib.sha256(raw).hexdigest()})
        records = []
        for number, line in enumerate(raw.decode('utf-8-sig', errors='replace').splitlines(), 1):
            if re.search(r'\bError(?::|\s+(?:in expression|Undefined|Missing|Generic|Type))|\| Error \|', line, re.I):
                errors.append([str(path), number, line])
            if f'[{tag}] ' not in line:
                continue
            payload = line.split(f'[{tag}] ', 1)[1]
            if payload.endswith('"'):
                payload = payload[:-1].replace('""', '"')
            try:
                name, _, value = payload.partition(' ')
                records.append([name, json.loads(value) if value else None])
            except (ValueError, TypeError):
                malformed.append([str(path), number, line])
        streams.append(records)
    srv, one, two = streams
    owner1 = one[0][1][0] if one and isinstance(one[0][1], list) and one[0][1] else None
    owner2 = two[0][1][0] if two and isinstance(two[0][1], list) and two[0][1] else None
    checks = {
        'distinct_remote_clients': type(owner1) is int and type(owner2) is int
            and owner1 > 2 and owner2 > 2 and owner1 != owner2,
        'server_lifecycle': srv == [
            ['ready', None], ['initial', [owner1, True, ['reset_before_join']]],
            ['removed', [True, []]], ['live', [owner1, []]],
            ['final', ['latest_native']], ['complete', None]],
        'first_join_and_live': one == [
            ['jip', [owner1, True, ['reset_before_join']]], ['live', [owner1, []]]],
        'second_join_after_native_reset': two == [
            ['jip', [owner2, True, ['latest_native']]], ['live', [owner2, ['latest_native']]]],
        'no_matched_errors': not errors,
        'no_malformed_records': not malformed,
    }
    return {'accepted': all(checks.values()), 'checks': checks, 'sources': sources,
            'records': streams, 'errors': errors, 'malformed': malformed}


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    for argument in ('server', 'first', 'second', 'output'):
        parser.add_argument(argument)
    args = parser.parse_args()
    result = collect(args.server, args.first, args.second)
    Path(args.output).write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({'accepted': result['accepted'], 'checks': result['checks']}))
    raise SystemExit(0 if result['accepted'] else 1)
