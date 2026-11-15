"""Extract exact marker geometry; one owner-authorized association correction."""
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
source = ROOT.parent / 'Zombie Occupant Faction/.work/ultimate/A3A/addons/maps/Antistasi_chernarusredux.chernarusredux/mission.sqm'
assert hashlib.sha256(source.read_bytes()).hexdigest() == '2c4d2556a1a534488f53fb3e3498640b0a40bdb38fb10c1feaec32851e2f43b0', 'Pinned upstream mission changed; review before regenerating'
markers = {}
shapes = {}
pattern = r'dataType="Marker";\s*position\[\]=\{([^}]+)\};\s*name="([^"]+)";(.*?)(?=^\s*\};)'
for match in re.finditer(pattern, source.read_text(encoding='utf-8-sig'), re.S | re.M):
    position = [float(n) for n in match[1].split(',')]
    def number(key, default):
        value = re.search(r'\b' + key + r'=([^;]+);', match[3])
        return float(value[1]) if value else default
    markers[match[2]] = ([position[0], position[2], 0], [number('a', 1), number('b', 1)], number('angle', 0))
    shape = re.search(r'markerType="([^"]+)";', match[3])
    shapes[match[2]] = shape[1] if shape else None

pairs = [('outp_6_vehicle', 'outpost_6')]
pairs += [(f'reso_{i}_vehicle_1', f'resource_{i}') for i in (1, 2, 3, 7)]
pairs += [('reso_13_vehicle_1', 'resource_10')]
rows = []
for parking, site in pairs:
    assert shapes[parking] == shapes[site] == 'RECTANGLE', 'Probe supports source rectangles only'
    # Resource 13 is absent upstream. Test its geometry against the existing
    # resource 10; the owner authorized best judgment on reconnecting this area.
    probe_name = 'reso_10_vehicle_1' if parking == 'reso_13_vehicle_1' else parking
    rows.append([probe_name, site, *markers[parking], *markers[site]])
test = ROOT / 'tests/markers.chernarusredux'
(test / 'markerData.sqf').write_text('// Extracted geometry; see source.json for the resource-10 association.\n' + json.dumps(rows, indent=2) + '\n', encoding='utf-8')
(test / 'source.json').write_text(json.dumps({
    'upstream_commit': 'c7c8247672ed5e7d4aa317d47efb371c41de4e7d',
    'source': 'A3A/addons/maps/Antistasi_chernarusredux.chernarusredux/mission.sqm',
    'sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
    'association_correction': {'from': 'reso_13_vehicle_1', 'to': 'reso_10_vehicle_1', 'site': 'resource_10'},
    'markers': rows,
}, indent=2) + '\n', encoding='utf-8')
for name in ('mission.sqm', 'description.ext'):
    (test / name).write_bytes((ROOT / 'tests/population.chernarusredux' / name).read_bytes())
