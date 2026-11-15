# RF-4: loot-crate save valuation

Owner decision, 15 November 2026: use the configured loot-crate price. The
follow-up clarification distinguishes save-time rally reimbursement from
rally-point purchase pricing, which uses a separate faction class.

Ultimate 12.4.2's `initUtilityItems` and `loot_createLootCrate` use
`lootCratePrice`. Its native `saveLoop` instead calls `vehiclePrice` with the
faction's loot-crate class. That utility class is absent from vehicle stock,
causing three errors and a 1000-money fallback. The call occurs even if there
are no crates to reimburse. Existing crates therefore receive the wrong saved
resource value, not merely a harmless log message.

On Redux, the wrapper returns the configured price for the selected Rebel
loot-crate class when the setting is a finite nonnegative number. It delegates
all other cases to the installed native function. It does not assign a new
price, change faction templates, alter vehicle discounts, or change the separate
rally-point class's purchase price. The native save routine's existing
loot-crate-based rally reimbursement formula consequently uses the corrected
crate price, as approved.

Focused evidence in `evidence/pricing-dev1` tests all five campaign price options
(100 through 500), a different faction crate class, discounts, the separate rally
class, and calls before crate settings/faction data exist. The baseline fails
seven of thirteen assertions; the fix passes all thirteen with no classified
script/native errors. Full native save and process-restart refund validation is
being collected in Infection's `codex/redux-pricing-validation` branch. No
client/UI or overall release certification is implied.

Run with `Tools/Start-PopulationProbe.ps1 -Suite Pricing -Mode Baseline|Fixed`
on distinct ports. `-World Altis -Mode Fixed` checks native pricing outside Redux.
The same evidence collector handles both pricing and population probes.
