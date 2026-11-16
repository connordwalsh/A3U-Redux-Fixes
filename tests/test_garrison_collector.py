import json
from pathlib import Path
import runpy
import tempfile
import unittest

module = runpy.run_path(str(Path(__file__).resolve().parents[1] / 'Tools/collect_garrison.py'))

class GarrisonCollector(unittest.TestCase):
    def test_complete_and_corrupted_records(self):
        rows = [['start', 'chernarusredux', True]]
        rows += [['check', name, True, []] for name in sorted(module['EXPECTED'])]
        rows += [['complete', len(module['EXPECTED']), []]]
        valid = '\n'.join('[REDUX_GARRISON] ' + json.dumps(row) for row in rows)
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'probe.rpt'
            path.write_text(valid)
            self.assertTrue(module['collect'](path, True)['accepted'])
            self.assertFalse(module['collect'](path, False)['accepted'])
            for damaged in (valid + '\nError: injected', valid + '\n' + valid,
                            valid.replace('concurrent_add_0', 'unknown_check'),
                            valid.rsplit('\n', 1)[0], valid.replace('"complete", 29', '"complete", 28')):
                path.write_text(damaged)
                self.assertFalse(module['collect'](path, True)['accepted'])

if __name__ == '__main__':
    unittest.main()
