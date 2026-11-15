# RF-1: rejected initial prototype

This feature branch is a development checkpoint, not a usable release.

The independent baseline and fixed probes ran on 15 November 2026 using
Ultimate, CBA, CUP Terrains Core and Redux. Neither Infection nor Zombies and
Creatures was loaded. Both completed their six assertions, but both emitted
native bad-population errors. The prototype therefore fails its acceptance
gate. The equality assertions alone do not discriminate this defect and need
stronger per-call evidence before they can support a fix claim.

The wrapper clears cached four-field display-name arrays only where a valid
configured population maps to an existing world location class. It delegates
the actual initialization to the installed Ultimate function. The remaining
errors require investigation; do not extend cache clearing or change map
populations without confirming the cause.

Evidence contains the original baseline and fixed RPT files, launch receipts
and the fixed build input manifest. Both isolated servers were stopped after
completion. The manual Infection installation was not modified.

Next acceptance steps: identify the remaining affected location keys, add
per-call population/error checks, repeat the paired test, verify non-Redux
delegation, then run full campaign startup and reload. No release or full
campaign acceptance is claimed.
