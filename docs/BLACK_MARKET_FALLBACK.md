# RF-5: valid black-market-only vehicle quotes

The parking campaign reload logged an error for O_Heli_Light_02_dynamicLoadout_F
during Bazaar activity. Ultimate 12.4.2's vehiclePrice logs a missing HQ price
before consulting its valid black-market fallback. The vanilla catalog contains
this helicopter at 28800. No new price or economy rule is introduced here.

On Redux, when the HQ entry is absent and a finite positive black-market entry
exists, the wrapper calls native blackMarketVehiclePrice and returns its finite
positive result. Discounts remain native. If either condition fails it delegates
to the original vehiclePrice, retaining diagnostics and the 1000 fallback for
invalid prices. Existing loot-crate handling, HQ-priced vehicles and other worlds
are preserved. This is a lookup correction, not a log filter.

Focused evidence:

- market-dev1: all 15 fixed checks pass without errors; the native baseline
  returns the same helicopter prices (28800, discounted 20571) but logs two
  false missing-HQ errors. It also retains the already-known loot-crate failures.
- negative-fixed-dev1: two intentionally invalid cases return the native 1000
  fallback and retain all five expected native diagnostics. The negative
  collector requires those errors; it does not weaken the positive/full-campaign
  clean-log gates.
- market-fixed-altis-dev1: native delegation passes two checks.

The full campaign probe now explicitly checks the real helicopter quote against
native blackMarketVehiclePrice and waits 75 seconds after saving/loading to
observe background activity before completion. Its original late error occurred
36 seconds after the old completion marker. Results are tracked separately in
Infection's codex/redux-market-validation branch. No client, performance or
release acceptance follows from these focused checks.
