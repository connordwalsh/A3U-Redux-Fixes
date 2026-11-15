# Compatibility backlog

Owner approved the public, independent A3U-Redux-Fixes repository on 15 November
2026. Scope is confirmed Ultimate/Redux compatibility defects, separate from
Infection gameplay.

- RF-1: Read-time population correction passes paired focused Redux checks.
  Altis delegation and full campaign save/reload population checks pass. Other
  campaign errors and client acceptance remain open; see POPULATION_FIX.md.
- RF-2: Investigate six short native vehicle-spawn markers. Not implemented.
- RF-3: Classify native no-player High Command/SmartMarker startup errors. Open.
- RF-4: Correct loot-crate save value to the owner-approved configured price.
  Thirteen focused checks pass; full native refund/reload validation in progress.
  See LOOT_CRATE_PRICE.md.

No sprint or release gate is closed. Preserve original map/mod files, isolate
tests and retain rejected reports. Do not suppress errors to make reports pass.
