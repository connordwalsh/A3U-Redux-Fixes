from pathlib import Path
import runpy
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
collect = runpy.run_path(str(ROOT / 'Tools/collect_hc.py'))['collect']


class HCEvidence(unittest.TestCase):
    def test_paired_native_results(self):
        for leader, name in [(False, 'hcempty'), (True, 'hcleader')]:
            self.assertTrue(collect(ROOT / f'evidence/hc-dev1/{name}.rpt', leader)['accepted'])

    def test_wrong_fixture_is_rejected(self):
        self.assertFalse(collect(ROOT / 'evidence/hc-dev1/hcempty.rpt', True)['accepted'])

    def test_extra_error_or_missing_completion_is_rejected(self):
        source = (ROOT / 'evidence/hc-dev1/hcleader.rpt').read_text(encoding='utf-8')
        for altered in [source + '\nError: unexpected\n',
                        source.replace('[REDUX_HC] complete', '[REDUX_HC] interrupted'),
                        source + source]:
            with tempfile.TemporaryDirectory() as directory:
                path = Path(directory) / 'probe.rpt'
                path.write_text(altered, encoding='utf-8')
                self.assertFalse(collect(path, True)['accepted'])


if __name__ == '__main__':
    unittest.main()
