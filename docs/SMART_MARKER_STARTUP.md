# RF-3: Old Man SmartMarker lifecycle guard

Arma 3 2.22 registers `BIS_fnc_OM_moduleSmartMarkers` as a preInit function.
The engine calls it with `["preInit"]`, but the installed handler does not
implement that mode. Without an Old Man marker module, it takes its error path.
Ultimate enables `allowFunctionsLog`, exposing the message during startup.
This is separate from the High Command/MARTA module.

Installed source inspected locally, not redistributed:

| Source | SHA-256 |
| --- | --- |
| missions_f_oldman/Systems/scripts/SmartMarkers/fn_OM_moduleSmartMarkers.sqf | 90f62bdf5a0552f406831943808c226e61dd7e4087b794333738d9c0b436c5ee |
| functions_f/initFunctions.sqf | 6f1af4b929dff0f2b02cc2ad0cf2e8c839665361d49e4f5b44a563a9be6d5fb8 |
| functions_f/debug/fn_logformat.sqf | 46203f39157c02e93ba264eed3351abfa213ac7d5203520d4d129ae30e8bc4aa |

The compatibility wrapper returns false only for the exact `["preInit"]` call
on Chernarus Redux. Every other input and world delegates to the installed
native script through a CfgFunctions alias. The explicit native addon dependency
establishes load order. Logging remains enabled; no error filter is relaxed.
The alias changes the function name shown in delegated diagnostic messages.

## Dedicated evidence

- `smart-dev1`: minimal Redux mission with function logging off/on, without
  Infection or this addon. Both have no SmartMarker logic; only the logging-on
  run emits the native startup message.
- `smart-fixed-dev1`: the same logging-on Redux fixture with the guard emits no
  error records, while leaving the marker module uninitialized.
- `smart-fixed-altis-dev1`: another world still takes the native path and emits
  the expected message.
- `smart-calls-dev1`: a real get-marker-name request without a module still
  returns false and emits the native error. This is an intentional negative
  control, not a clean campaign run.

All runs retain complete logs, launch identities, parsed results and the tested
addon manifest. The collector requires exact expected records/errors and rejects
missing completion, extra runs and unexpected errors. Fixtures do not replace
the production handler or disable diagnostic logging.

Full native Infection campaign startup/save/process-restart/reload with this
build passes 16 assertions per phase and 75-second background windows. Both
logs omit the SmartMarker startup error but retain five other error records:
HC's missing leader (two records), missing objects (two) and an addon-init error.
The campaign collector was corrected to catch uppercase ERROR too; the older
market log has six matching records under the corrected rule, rather than the
five originally reported. Original failed reports are preserved.

See Infection branch `codex/redux-smart-validation`, its
`docs/research/REDUX_SMART_VALIDATION.md` and retained complete logs. Eight
campaign collector/parser tests and 24 independent evidence tests pass.
Connected-player UI, actual Old Man marker operations and release acceptance
are not certified. No manual installation or engine source was changed.
