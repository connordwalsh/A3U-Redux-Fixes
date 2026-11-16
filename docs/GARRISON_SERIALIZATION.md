# Garrison update serialization

Native Liquidation investigation on 16 November 2026 found that simultaneous
defender deaths can leave stale entries in Ultimate's saved garrison. Infection's
clearance ledger correctly counted all 16 deaths, but native roster entries
remained and prevented mission capture.

The instrumented native receiver recorded all 16 entries and all 16 exits.
Its roster snapshots regained roles removed by preceding calls, demonstrating
overlapping read/modify/write operations. The native scheduled mutex check and
assignment are separate operations; a scheduler interruption can let another
update pass the check before acquisition. The trace run is diagnostic evidence,
not acceptance, and its completion and exact archive remain pending.

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
The full native Liquidation run with this candidate is separately pending.
