import importlib.util
from pathlib import Path
import unittest

ROOT=Path(__file__).resolve().parents[1]
def module(name):
    spec=importlib.util.spec_from_file_location(name,ROOT/'Tools'/f'{name}.py')
    result=importlib.util.module_from_spec(spec);spec.loader.exec_module(result)
    return result
markers=module('collect_markers')
parking=module('collect_population')

class MarkerEvidence(unittest.TestCase):
    def test_settled_physics_and_footprints(self):
        base=ROOT/'evidence/markers-dev4'
        result=markers.collect(base/'diagnostic.rpt',base/'source.json')
        self.assertTrue(result['accepted'])
        self.assertEqual(len([r for r in result['records'] if r[0]=='vehicle']),24)

    def test_clearance_failures_are_not_hidden_by_stable_vehicles(self):
        base=ROOT/'evidence/markers-dev3-rejected'
        result=markers.collect(base/'diagnostic.rpt',base/'source.json')
        self.assertFalse(result['accepted'])
        self.assertFalse(result['checks']['vehicle_checks_pass'])

    def test_native_slots_and_guards(self):
        result=parking.collect(ROOT/'evidence/parking-fixed-dev1/probe.rpt')
        self.assertTrue(result['accepted'])
        self.assertEqual(len(result['checks']),14)

    def test_other_world_unchanged(self):
        self.assertTrue(parking.collect(ROOT/'evidence/parking-fixed-altis-dev1/probe.rpt')['accepted'])

if __name__=='__main__':
    unittest.main()
