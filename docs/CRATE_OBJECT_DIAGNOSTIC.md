# Remaining startup object errors: crate investigation

Status: unresolved. No production fix or release gate is claimed here.

The full campaign trace observed HQ crate `boxX` (`IG_supplyCrate_F`) at
network ID `2:8`, followed by missing-object errors for `2:9` and `2:10`.
The next observed mission logic was `2:19`. This suggested investigating
objects contained in the crate; it did not identify the missing objects.

## Working runtime experiment

`evidence/crate-runtime-dev1` preserves the exact fixture, launch receipt,
and raw server log. It uses the existing version-12 minimal probe mission,
creates a crate after mission startup, records its containers, and calls the
installed `BIS_fnc_initAmmoBox` with the upstream empty-string argument.

Observed results:

- `A3_Characters_F` exists. `unitAddons` reports that patch for the upstream
  observer type, and `A3_Weapons_F_Ammoboxes` for the crate.
- The crate is `2:92`; its two `B_TacticalPack_blk` backpacks are `2:93` and
  `2:94`. Eight vest containers occupy `2:95` through `2:102`.
- The empty-string initializer emits undefined-variable diagnostics for
  `_data` and `_isVirtual` in the installed native function.
- After the call, both the container list and backpack cargo are empty.
- The experiment reaches its completion marker. It does **not** reproduce
  the campaign's missing-object errors.

The backpack ID ordering fits the campaign observation, but runtime creation
and mission-initialization creation are different conditions. The cause of the
campaign errors therefore remains unproven. The native empty-string script
diagnostics are also distinct from those two campaign records.

## Rejected Eden fixtures

`Tools/extract_crate_probe.py` pins the official mission hash and extracts its
HQ crate into paired stock and empty-inventory fixtures. The stock variant
removes only the inventory attribute; the other retains it.

- `crate-dev1-rejected`: abbreviated mission header; both missions rejected.
- `crate-dev2-rejected`: original full header; both missions rejected.
- `crate-dev3-rejected`: additionally preserves the exact upstream commander
  object definition (renamed for the probe); stock mission still rejected.

Each rejection reports missing `a3_characters_f` content before the probe runs.
The runtime experiment proves that patch exists in the loaded stack; it does
not explain this fixture-loading failure. These are failed preparations, not
evidence for or against crate startup behavior. All processes were explicitly
stopped after executable and dedicated-profile checks.

## Next investigation

The follow-up `crate-placed-dev1` pair uses version-12 mission objects and their
startup init fields. Both complete. Stock cargo retains the two backpacks at
`2:8` and `2:9` beneath crate `2:7`; the empty variant removes all ten containers.
Neither emits the missing-object records. Unlike the later runtime call, the
startup empty-string call also produces no undefined-variable diagnostics.
This demonstrates that call timing/context matters. It does not reproduce the
Eden attribute path or establish that the complete campaign is error-free.

The generator is `Tools/create_placed_crate_probe.py`; its fixtures deliberately
use the known-working version-12 format rather than claiming to repair Eden
loading. Next, trace the installed initializer in the complete official mission.

Use a working startup fixture to compare stock cargo with explicit empty cargo,
then confirm any finding in the complete native campaign. Do not suppress
missing-object logs, remove HQ functionality, or change general crate behavior
merely to obtain a clean report. Connected-player and manual testing remain
outstanding; this investigation used no Computer Use.
