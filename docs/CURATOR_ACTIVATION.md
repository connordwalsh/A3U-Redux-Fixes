# RF-3: redundant Curator addon activation

The installed Curator module requests all CfgPatches when configured with
Addons=3, then requests synchronized future addons. Official Redux uses that
setting. The native activation helper rejects calls after time 0 before checking
whether the requested addons are already active.

Infection's bounded startup trace records all 2874 requested patches already
active (case-normalized identity comparison), followed by an empty request.
Both native requests report a timing error even though neither requires a new
activation. Raw name subtraction alone was misleading because class-name case
differs; preserved intermediate traces document that distinction.

The compatibility wrapper handles only server-side Redux calls after time 0
with an array of strings naming already-active patches. It returns the current
active set without performing activation. A fresh lowercase lookup avoids
quadratic membership work and does not cache potentially stale addon state.
Early calls, other worlds/clients, malformed inputs, object-class requests and
any request containing an inactive/unknown patch still use the native handler.
This does not grant additional Curator access or enable late addon activation.

Focused evidence:

- `activation-baseline-dev1`: native early behavior works; four late calls emit
  the native timing error and return empty results.
- `activation-fixed-dev1`: early behavior remains native; uppercase already-
  active names and empty requests return the unchanged active set. Unknown and
  malformed requests retain both native errors and empty return values.
- `activation-altis-dev1`: all four late requests retain native behavior. The
  existing native Old Man SmartMarker error is also required by the Altis
  collector. The initial parser report omitted that known diagnostic and failed;
  it is preserved alongside the corrected explicit five-error expectation.

All 31 evidence tests pass. Full native campaign validation is pending. Source
inspection hashes and complete instrumented traces are in Infection's
`docs/research/STARTUP_TRACE.md`; the trace is diagnosis, not clean-log acceptance.
No engine source is redistributed, and no manual installation is modified.
