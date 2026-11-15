from pathlib import Path
import runpy
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
collect = runpy.run_path(str(ROOT / 'Tools/collect_smart.py'))['collect']


class SmartEvidence(unittest.TestCase):
    def test_native_logging_pair(self):
        self.assertTrue(collect(ROOT / 'evidence/smart-dev1/smartquiet.rpt', False)['accepted'])
        self.assertTrue(collect(ROOT / 'evidence/smart-dev1/smartlogged.rpt', True)['accepted'])

    def test_fixed_startup_and_other_world(self):
        self.assertTrue(collect(ROOT / 'evidence/smart-fixed-dev1/probe.rpt', True, True)['accepted'])
        self.assertTrue(collect(ROOT / 'evidence/smart-fixed-altis-dev1/probe.rpt', True, True, True)['accepted'])

    def test_actual_invalid_request_still_diagnosed(self):
        self.assertTrue(collect(ROOT / 'evidence/smart-calls-dev1/probe.rpt', True, True, calls=True)['accepted'])

    def test_missing_error_or_completion_rejected(self):
        source = (ROOT / 'evidence/smart-calls-dev1/probe.rpt').read_text(encoding='utf-8')
        for altered in [source.replace('Error: SmartMarker', 'Omitted: SmartMarker'),
                        source.replace('[REDUX_SMART_CALL] complete', 'interrupted'),
                        source + '\nError: unexpected\n', source + source]:
            with tempfile.TemporaryDirectory() as directory:
                path = Path(directory) / 'probe.rpt'
                path.write_text(altered, encoding='utf-8')
                self.assertFalse(collect(path, True, True, calls=True)['accepted'])


if __name__ == '__main__':
    unittest.main()
