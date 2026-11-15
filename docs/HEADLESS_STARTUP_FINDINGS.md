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
