# Garrison update serialization

Native Liquidation investigation on 16 November 2026 found that simultaneous
defender deaths can leave stale entries in Ultimate's saved garrison. Infection's
clearance ledger correctly counted all 16 deaths, but native roster entries
remained and prevented mission capture.

The instrumented native receiver recorded all 16 entries and all 16 exits.
Its roster snapshots regained roles removed by preceding calls. The separate
scheduled mutex check and assignment suggested overlapping read/modify/write
operations, but the first serialization candidate did not resolve the defect.
The precise mechanism is still unproven. The completed trace is diagnostic
evidence, not acceptance.

The fix delegates to the unchanged Ultimate implementation in an unscheduled
transaction only when its shared mutex is free. Waiting remains scheduled;
ownership checks, role conversion, add/remove behavior and marker updates remain
native. Unscheduled callers are moved to a scheduled worker before waiting.

Validation pending: build, actual native queued-defender Liquidation completion,
simultaneous additions/removals, occupied mutex, ownership rejection, and ordinary
campaign behavior. No release certification or player/multiplayer claim.

Build passed. The native receiver trace completed with 16 received/finished
updates but two stale roles, five failed mission checks and 19 passing campaign
checks. Infection's `native-liquidation-diag4-rejected` preserves that evidence.

The independent focused fixture currently fails concurrent additions and mutex
checks in both Fixed and Baseline controls. Fixed Dev2 logs all 128 worker handles
as finished before each assertion, but still fails. Preserve these rejected
results; the worker/call lifecycle needs further investigation before attributing
every focused failure to production. The candidate has not passed acceptance.
Fixed Dev3 confirms the candidate function is compiled, but still fails 12 of
27 focused checks. The compiled native-function log is truncated by the engine's
log-line limit and must not be treated as a complete runtime-code dump.

The full native Liquidation run with the candidate also retains three roster
entries after all defenders die. The configured receiver path points to the fix.
This candidate is rejected, not ready to merge. Next investigation should record
execution context, arguments and before/after state inside the candidate's
transaction, and verify whether roster changes occur after worker completion.
Do not weaken the clearance gate or discard persistent roster entries.

## Publication controls

Transaction Dev4 recorded the delegated native mutation but did not reach the
following diagnostic statement; repeated attempts produced engine GIAS stack
errors. It was stopped and all errors are preserved. Direct atomic mutation
(Dev5) and explicit worker completion counters (Dev6) still failed. The counters
recorded matching entries/exits for all workers, ruling out the initial suspicion
that the test simply failed to wait for them.

Changing only the publication flag to false in Dev7 passed all 27 local checks
with zero errors. This is a diagnostic control only: it removes multiplayer/JIP
publication and must never be deployed as a fix. Restoring publication with a
separate entry lock and a scheduled native call (Dev8, current candidate) failed
again. The next comparison changes only the namespace storage object.

Dev9's game-logic comparison was invalid because createVehicle did not create the
logic. The corrected control uses createUnit in a sideLogic group. This also
exposed a weak earlier object-role test: a null object could leave the roster
unchanged and pass its round-trip assertion. The current 29-check collector now
requires a real object and verifies its role is actually appended before removal.
Earlier 27-check archives do not prove object-role conversion.
