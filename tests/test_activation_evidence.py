from pathlib import Path
import runpy
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]
collect=runpy.run_path(str(ROOT/'Tools/collect_activation.py'))['collect']


class ActivationEvidence(unittest.TestCase):
    def test_baseline_and_fixed(self):
        self.assertTrue(collect(ROOT/'evidence/activation-baseline-dev1/probe.rpt')['accepted'])
        self.assertTrue(collect(ROOT/'evidence/activation-fixed-dev1/probe.rpt',True)['accepted'])

    def test_altis_retains_native_behavior_and_diagnostics(self):
        self.assertTrue(collect(ROOT/'evidence/activation-altis-dev1/probe.rpt',altis=True)['accepted'])

    def test_missing_negative_error_and_extra_run_rejected(self):
        source=(ROOT/'evidence/activation-fixed-dev1/probe.rpt').read_text(encoding='utf-8')
        for altered in [source.replace('The function can be activated only during the mission init.','Omitted'),
                        source.replace('[REDUX_ACTIVATION] complete','interrupted'),
                        source+'\nERROR: unexpected\n',source+source]:
            with tempfile.TemporaryDirectory() as directory:
                path=Path(directory)/'probe.rpt';path.write_text(altered,encoding='utf-8')
                self.assertFalse(collect(path,True)['accepted'])


if __name__=='__main__':unittest.main()
