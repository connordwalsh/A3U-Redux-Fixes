# Compatibility backlog

Owner approved the public, independent A3U-Redux-Fixes repository on 15 November
2026. Scope is confirmed Ultimate/Redux compatibility defects, separate from
Infection gameplay.

- RF-1: Read-time population correction passes paired focused Redux checks.
  Altis delegation and full campaign save/reload population checks pass. Other
  campaign errors and client acceptance remain open; see POPULATION_FIX.md.
- RF-2: Footprint-preserving parking correction and resource-10 reconnection
  pass terrain probes (24 vehicles), 14 native-slot/guard checks and Altis
  preservation. Full native save/reload passes 13 assertions per phase and has
  no marker errors; startup/object and a later helicopter-price error remain. See
  VEHICLE_MARKER_DIAGNOSTIC.md.
- RF-3: Native empty-leader HC failure reproduced in paired diagnostics.
  Old Man SmartMarker preInit guard passes Redux, Altis delegation and actual
  invalid-request checks; see SMART_MARKER_STARTUP.md.
  High Command now defers startup until a leader is synchronized; eight focused
  lifecycle checks and full campaign save/reload pass, with missing-leader errors
  absent. Curator's redundant late addon requests now return the already-active
  set; full native save/reload passes 18 assertions per phase with all Curator
  addons preserved and no activation error. Two missing-object errors remain.
  See HIGH_COMMAND_STARTUP.md and CURATOR_ACTIVATION.md; client acceptance is open.
- RF-4: Correct loot-crate save value to the owner-approved configured price.
  Thirteen focused and two Altis checks pass; full native refund/reload passes
  eleven assertions per phase. Other campaign errors remain open.
  See LOOT_CRATE_PRICE.md.
- RF-5: Valid black-market-only quotes incorrectly log a missing HQ price.
  Corrected native fallback passes 15 positive checks, two negative cases with
  required diagnostics, and Altis delegation. Full campaign write/reload each
  pass 16 assertions including a 75-second background window, without pricing
  errors. Five startup/object records still fail the clean-log gate;
  see BLACK_MARKET_FALLBACK.md.

No sprint or release gate is closed. Preserve original map/mod files, isolate
tests and retain rejected reports. Do not suppress errors to make reports pass.
