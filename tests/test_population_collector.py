import importlib.util
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('collector', ROOT / 'Tools/collect_population.py')
collector = importlib.util.module_from_spec(spec)
spec.loader.exec_module(collector)


class EvidenceTests(unittest.TestCase):
    def test_fixed_evidence(self):
        self.assertTrue(collector.collect(ROOT / 'evidence/population-dev3/Fixed.rpt')['accepted'])

    def test_altis_delegation_evidence(self):
        self.assertTrue(collector.collect(ROOT / 'evidence/population-altis-dev1/Fixed.rpt')['accepted'])

    def test_native_errors_reject_even_with_green_assertions(self):
        result = collector.collect(ROOT / 'evidence/population-dev3/Baseline.rpt')
        self.assertFalse(result['accepted'])
        self.assertEqual(result['failed_checks'], [])
        self.assertEqual(len(result['errors']), 98)

    def test_missing_completion_rejected(self):
        self.mutated('""complete""', '""incomplete""')

    def test_missing_town_check_rejected(self):
        self.mutated('call_2_city_Chernogorsk', 'unexpected_check')

    def mutated(self, before, after):
        source = (ROOT / 'evidence/population-dev3/Fixed.rpt').read_text(encoding='utf-8')
        self.assertIn(before, source)
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'probe.rpt'
            path.write_text(source.replace(before, after), encoding='utf-8')
            self.assertFalse(collector.collect(path)['accepted'])


if __name__ == '__main__':
    unittest.main()
