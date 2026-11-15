from pathlib import Path
import runpy
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]
collect=runpy.run_path(str(ROOT/'Tools/collect_population.py'))['collect']
negative=runpy.run_path(str(ROOT/'Tools/collect_market_negative.py'))['collect']

class MarketEvidence(unittest.TestCase):
    def test_valid_prices_and_discounts(self):
        result=collect(ROOT/'evidence/market-dev1/Fixed.rpt')
        self.assertTrue(result['accepted'])
        self.assertEqual(len(result['checks']),15)

    def test_native_reports_error_despite_correct_fallback(self):
        result=collect(ROOT/'evidence/market-dev1/Baseline.rpt')
        checks={row[1]:row[2] for row in result['checks']}
        self.assertTrue(checks['black_market_only_price'])
        self.assertTrue(checks['black_market_only_discount'])
        self.assertEqual(sum('Invalid vehicle price :O_Heli_Light_02_dynamicLoadout_F' in e for e in result['errors']),2)

    def test_native_invalid_price_diagnostics_retained(self):
        result=negative(ROOT/'evidence/negative-fixed-dev1/probe.rpt')
        self.assertTrue(result['accepted'])
        self.assertEqual(len(result['errors']),5)

    def test_missing_negative_diagnostic_is_rejected(self):
        source=(ROOT/'evidence/negative-fixed-dev1/probe.rpt').read_text(encoding='utf-8')
        lines=[line for line in source.splitlines() if 'Invalid vehicle price at O_Truck_03_transport_F' not in line]
        with tempfile.TemporaryDirectory() as directory:
            path=Path(directory)/'missing.rpt';path.write_text('\n'.join(lines),encoding='utf-8')
            self.assertFalse(negative(path)['accepted'])

    def test_altis_delegates(self):
        self.assertTrue(collect(ROOT/'evidence/market-fixed-altis-dev1/probe.rpt')['accepted'])

if __name__=='__main__':unittest.main()
