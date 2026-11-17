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

## Publication overwrite isolated; transport validation incomplete

Dev10 through Dev14 are preserved with exact test inputs and logs. Corrected object creation and actual object-role insertion are included in the 29-check collector. Proper game-logic storage, initialized network IDs, waiting an additional frame between writes, and disabling the launcher's loopback setting did not resolve lost updates.

Dev14 directly writes [1] publicly, [2] publicly, then [3] locally in one unscheduled block. Immediate reads reflect each write, but after 0.2 seconds and after 1 second the value is [2]. This reproduces delayed overwrite without garrisonUpdate and shifts the investigation from the proposed lock to publication. The frame-wait candidate remains rejected; do not merge or deploy it.

Dev15 attempts a late-joining headless-client comparison of boolean publication against numeric -2 publication. The server times out waiting for the client. Neither late-join nor live synchronization is established. The client never logs mission entry. Socket inspection found overlapping port 11004 bindings, but the cause is unproven. Both isolated processes were stopped and absence verified before archiving. See evidence/garrison-publication-client-dev15-timeout.

Next gate: establish a working local headless connection and verify late-join plus live values before selecting any replacement publication mechanism. Removing public synchronization is not an acceptable fix. Then rerun the 29-check garrison suite and the real Infection Liquidation campaign test. No additional faction development is in scope.

## Native client result (Dev18)

A client bound to 127.0.0.2 successfully joined the server bound to 127.0.0.1 after disabling the loopback-only server setting. Dev16 timed out and Dev17 was aborted after menu loops; both are preserved. Dev18 completes on both server and headless client. Initial JIP values: global [11], numeric -2 []. Live values: global [33], numeric -2 [44]. Numeric publication alone is rejected as a production fix because it does not provide the required initial snapshot to late joiners. The next candidate needs explicit persistent client delivery while keeping authoritative server writes local, followed by focused and native campaign regression tests.

## Connected-client and persistent-delivery controls

Dev19 reproduces the publication overwrite with a connected headless client: 29 checks, 11 failures, zero matched errors. The local [3] control again reverts to published [2]. This is not limited to an empty server.

Dev20 confirms remoteExecCall setVariable targeted to -2 with a stable JIP identifier delivers [55] to the first late joiner, [66] live, and [66] to a subsequent fresh joiner. The server retains its deliberate local [77]. No garrison integration is accepted yet: direct native writes outside garrisonUpdate can make a stored JIP roster stale. The integration must preserve current authoritative state after capture/reset/load as well as concurrent casualties.

## Candidate: local transaction and current-state JIP request

The new candidate writes the authoritative roster locally inside the transaction, then delivers it to clients with a persistent receiveGarrison call. Live delivery applies the roster only on clients and only when sent by the server. JIP execution treats the persistent entry as a request token: sendGarrison validates the campaign namespace and returns its current roster. This avoids restoring a stale cached roster after a native reset/capture/load.

Dev21: all 29 native focused checks pass, zero matched errors. Dev22: first late join receives a native reset made after the patched update; 64 concurrent casualties leave an empty roster on server and client; a second fresh join receives a subsequent native reset rather than the old persistent empty value. Raw logs and exact production inputs are preserved. Real Liquidation campaign validation remains required; no merge or production deployment is approved yet.

## Real Infection campaign regression passed

Infection branch codex/campaign-liquidation evidence/sprint-6/native-liquidation-fixed2 records all 17 Liquidation and 19 campaign checks passing with zero matched errors using candidate PBO F828C0F035266CFA93B165FAA91ECA6877108DB6FE09D66F699976E7D6C3551D. Factory_9 retains 16 defenders (12 active, four queued), reaches an empty native roster after all defenders die, transfers ownership, succeeds the task, pays exactly 800 once, and cleans up. This supersedes the rejected candidate results. Companion review/merge and broader release gates remain open; no manual Dev9 update occurred.
