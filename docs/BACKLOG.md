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
- RF-3: Classify native no-player High Command/SmartMarker startup errors. Open.
- RF-4: Correct loot-crate save value to the owner-approved configured price.
  Thirteen focused and two Altis checks pass; full native refund/reload passes
  eleven assertions per phase. Other campaign errors remain open.
  See LOOT_CRATE_PRICE.md.
- RF-5: Classify O_Heli_Light_02_dynamicLoadout_F vehicle-price error recorded
  after the parking reload assertions completed. Open; not a loot-crate failure.

No sprint or release gate is closed. Preserve original map/mod files, isolate
tests and retain rejected reports. Do not suppress errors to make reports pass.
