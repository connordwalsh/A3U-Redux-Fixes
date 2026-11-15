from pathlib import Path
import runpy
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
collect = runpy.run_path(str(ROOT / 'Tools/collect_hc_delay.py'))['collect']
native = runpy.run_path(str(ROOT / 'Tools/collect_hc.py'))['collect']


class HCDelayEvidence(unittest.TestCase):
    def test_delayed_native_lifecycle(self):
        self.assertTrue(collect(ROOT / 'evidence/hc-deferred-dev1/probe.rpt')['accepted'])

    def test_ready_leader_and_other_world(self):
        for folder in ['hc-ready-dev1', 'hc-altis-dev1']:
            self.assertTrue(native(ROOT / f'evidence/{folder}/probe.rpt', True)['accepted'])

    def test_marta_cause_not_reproduced(self):
        for name in ['hclogged', 'hcmarta']:
            self.assertTrue(native(ROOT / f'evidence/hc-logging-dev1/{name}.rpt', True)['accepted'])

    def test_missing_failed_or_extra_evidence_rejected(self):
        source = (ROOT / 'evidence/hc-deferred-dev1/probe.rpt').read_text(encoding='utf-8')
        for altered in [source.replace('late_leader_bound', 'wrong_check'),
                        source.replace('""late_leader_bound"",true', '""late_leader_bound"",false'),
                        source.replace('[REDUX_HC_DELAY] complete', 'interrupted'),
                        source + '\nERROR: unexpected\n', source + source]:
            with tempfile.TemporaryDirectory() as directory:
                path = Path(directory) / 'probe.rpt'
                path.write_text(altered, encoding='utf-8')
                self.assertFalse(collect(path)['accepted'])


if __name__ == '__main__':
    unittest.main()
