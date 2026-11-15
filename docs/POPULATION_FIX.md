# RF-1: repeated town initialization

Target: Ultimate 12.4.2, upstream commit
`c7c8247672ed5e7d4aa317d47efb371c41de4e7d`, Arma 3 2.22.

Ultimate's `initVarCommon` loads town data before `initZones` loads it again.
`getCityData` writes a four-field row under each town's display name. The next
call selects that row ahead of the numeric config-name population, logs an
error, and counts houses instead. In the isolated baseline, those house counts
matched the configured values; equality assertions therefore passed despite
98 logged errors across the second and third calls.

The Redux override retains the upstream function body and changes the lookup:
when a display-name value is a four-field array, read the configured class-name
value instead. Numeric display-name overrides retain native precedence. Invalid
or missing configured data retains native error reporting and fallback. Other
worlds delegate to the installed upstream function. This does not change any
map population or Infection density rule.

The earlier cache-clearing wrapper is rejected. Its remaining errors reproduced
despite all 49 config keys resolving to valid town classes. The replacement
handles the collision at the actual read rather than deleting namespace data.
The precise reason for the earlier wrapper's incomplete effect is not proven.

## Evidence

- `evidence/population-dev1`: rejected cache-clearing prototype and baseline.
- `evidence/population-dev2`: rejected diagnostic run, all config keys valid.
- `evidence/population-dev3`: same fixture for baseline and revised fix;
  153 assertions each, 98 native population errors in baseline, zero in fixed.
  The collector rejects baseline even though every assertion passes.
- Five collector regression tests verify accepted evidence and rejection of
  native errors, missing completion and a missing expected town check.
- `evidence/population-altis-dev1`: two assertions pass; the override delegates
  unchanged native data for all 47 Altis towns, with no script/native errors.
  Its rebuild has the same production input hashes as Redux dev3; PBO packing
  timestamps differ. Attribution is included in the rebuilt mod folder.

The full Infection campaign companion run also passes nine save and ten
process-restart reload assertions, with zero population errors. Its unchanged
clean-log gate remains failed on 14 writer and 11 reader records from other
startup/marker/pricing issues. Full evidence is tracked in the Infection repo's
`codex/redux-companion-validation` branch under `evidence/sprint-4/redux-companion-*`
and `docs/research/REDUX_COMPANION_VALIDATION.md`.

These are dedicated-engine checks without a player. Existing terrain
model/geometry warnings remain visible in the raw logs and are not certified
away by the population check. Remaining full-campaign errors and client checks
remain open before release.

## Reproduction

Build with `Tools/Build.ps1` and the installed Arma Tools path. Launch isolated
paired runs with `Tools/Start-PopulationProbe.ps1 -Mode Baseline` and `-Mode Fixed`
on distinct ports. Use `-World Altis -Mode Fixed` for native delegation. Collect
with `python Tools/collect_population.py <rpt> <report.json>`. Stop only the
receipt-identified server after completion before rebuilding or relaunching.

The override incorporates upstream MIT-licensed code. Full upstream notices
are retained in `THIRD_PARTY_LICENSES.txt` and copied into the built mod folder.
