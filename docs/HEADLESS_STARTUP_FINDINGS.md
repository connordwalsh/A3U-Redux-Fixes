# RF-3: no-player startup investigation (not yet resolved)

The remaining campaign logs contain High Command's undefined `_leader`, a
SmartMarker initialization error, and two missing-object messages. They must
remain in the failed clean-log reports until classified or corrected.

Local source inspection on 15 November 2026 found:

- The official Redux mission connects HighCommand object 33 (HC_commanderX) to
  HighCommandSubordinate 34 and playable commanderX object 36.
- Ultimate's MissionDescription/gameSettings.hpp sets disabledAI to 1.
- Installed Arma 3 modules_f/hc/data/scripts/hc.sqf allows the main HC scope past
  its synchronization wait even with no non-subordinate synchronized objects.
  It then selects element zero as leader and immediately uses it without an
  empty-list guard. This matches the location of the observed undefined-variable
  error. The extracted script SHA-256 is
  6dc4efd1b17353a572502d3bf57c5b9b67dd08295b6ecf923aed6bdef818641c.

This is a source-backed explanation to investigate, not proof that every remaining
error is caused by missing players or that a connected-player campaign is clean.
Next evidence should record the live HC synchronization state and compare a
controlled leader-present case. SmartMarker and missing-object records still
need separate tracing. No Bohemia source files are redistributed here, and no
engine module or manual-install file was changed.

## Paired native-module diagnostic, 15 November 2026

`evidence/hc-dev1` retains complete logs, launch identities and parsed results.
Both dedicated servers loaded CBA, Ultimate, CUP Terrains Core and Redux, with
zero connected players and without Infection or this compatibility addon.
The fixtures create the installed native HC module and subordinate, then
synchronize them in the same unscheduled block before its native script runs.
Only the leader-present fixture adds a synchronized independent AI commander.

- Empty leader list: reproduced the undefined `_leader` expression; the main
  scope existed, but no commander was bound.
- Leader present: the native scope bound to the commander and no error records
  occurred in the complete log.
- Both initialized a MARTA scope. Neither reproduced the campaign SmartMarker
  or missing-object errors, so those require separate investigation.

The collector requires exactly the two expected error records for the empty
case and zero for the leader case. It rejects incomplete or extra runs and
unexpected errors. The servers were stopped after checking their executable
and dedicated profile identities. No production override was added.

This establishes the native module's empty-synchronization failure in isolation.
It does not yet establish the live synchronization state in the full campaign,
prove that a connected player resolves all startup errors, or close RF-3.

## Follow-up evidence

The full Infection campaign's read-only module snapshot now confirms zero
players, absent commanderX and a live HC scope synchronized only to its
subordinate. See Infection's `REDUX_SMART_VALIDATION.md` and retained logs.
The SmartMarker error has a separate Old Man lifecycle cause and a focused
guard; see SMART_MARKER_STARTUP.md.

The campaign collector also missed uppercase `ERROR:` records. Case-insensitive
matching exposes an additional `BIS_fnc_activateAddons` initialization-time error
already present in prior logs. The native HC script calls `activateAddons` when
creating MARTA (line 37 of the hash-pinned local script). This is a source lead
to reproduce with function logging enabled, not yet a proven causal diagnosis.
Existing campaign reports already failed; original logs/reports are preserved.

The subsequent HC logging/MARTA pair did not reproduce the addon-init error.
Full campaign runs with native HC deferred still emit it before HC starts, so
the HC/MARTA lead does not establish its cause. Deferral itself removes both
missing-leader expression records and passes native save/reload; see
HIGH_COMMAND_STARTUP.md. Missing objects and addon activation remain unresolved.

Bounded follow-up tracing identifies redundant Curator addon-activation requests,
not HC/MARTA, as the timing-error path. The late requests contain no missing
case-normalized addon identities. The guard and uninstrumented campaign
validation are documented in CURATOR_ACTIVATION.md. Both full campaign phases
now retain only the two missing-object error records. Their entities are still
unidentified; early event tracing did not establish their creation or deletion.
