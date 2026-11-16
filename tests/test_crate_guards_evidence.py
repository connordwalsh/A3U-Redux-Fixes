import importlib.util
from pathlib import Path
import tempfile
import unittest

spec=importlib.util.spec_from_file_location('crate_collector',Path(__file__).resolve().parents[1]/'Tools/collect_crate_guards.py')
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)

class CrateEvidenceTests(unittest.TestCase):
    def collect(self,extra='',altis=False,omit=None):
        text='\n'.join(f'[REDUX_CRATE_GUARDS] ["{name}",true]' for name in sorted(module.EXPECTED) if name!=omit)
        text+='\n[REDUX_CRATE_GUARDS] complete\n'+extra
        with tempfile.TemporaryDirectory() as directory:
            path=Path(directory)/'test.rpt';path.write_text(text)
            return module.collect(path,altis)

    def test_complete_set_required(self):
        self.assertTrue(self.collect()['accepted'])
        self.assertFalse(self.collect(omit='getter_native')['accepted'])

    def test_extra_errors_rejected(self):
        self.assertFalse(self.collect('Error: Object(2 : 9) not found')['accepted'])
        native='Error: SmartMarker system has not been yet initialized.'
        self.assertTrue(self.collect(native,True)['accepted'])
        self.assertFalse(self.collect(native+'\nERROR: unexpected',True)['accepted'])

    def test_duplicate_and_false_rejected(self):
        self.assertFalse(self.collect('[REDUX_CRATE_GUARDS] ["getter_native",true]')['accepted'])
        self.assertFalse(self.collect('[REDUX_CRATE_GUARDS] ["getter_native",false]',omit='getter_native')['accepted'])

if __name__=='__main__':unittest.main()
