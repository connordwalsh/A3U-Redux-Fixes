import runpy
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
collect = runpy.run_path(str(ROOT / 'Tools/collect_garrison_sync.py'))['collect']


class SyncCollector(unittest.TestCase):
    def test_native_evidence_and_invalid_variants(self):
        evidence = ROOT / 'evidence/garrison-sync-dev22'
        originals = [next((evidence / part).glob('*.rpt')).read_text(encoding='utf-8-sig')
                     for part in ('server', 'first-client', 'second-client')]
        with tempfile.TemporaryDirectory() as directory:
            paths = [Path(directory) / f'{index}.rpt' for index in range(3)]

            def check(texts):
                for path, text in zip(paths, texts):
                    path.write_text(text, encoding='utf-8')
                return collect(*paths)['accepted']

            self.assertTrue(check(originals))
            variants = [
                [originals[0].replace('[GARRISON_SYNC] complete', '[OTHER] complete'), *originals[1:]],
                [originals[0] + '\nError: injected\n', *originals[1:]],
                [originals[0], originals[1] * 2, originals[2]],
                [*originals[:2], originals[2].replace('latest_native', 'stale_roster')],
                [*originals[:2], originals[2].replace('[5,true', '[4,true').replace('[5,[', '[4,[')],
                [*originals[:2], ''],
            ]
            for index, variant in enumerate(variants):
                with self.subTest(index=index):
                    self.assertFalse(check(variant))
