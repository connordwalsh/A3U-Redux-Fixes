# RF-2: Redux vehicle parking investigation

The pinned Ultimate mission defines six parking rectangles with a length below
the native ten-metre requirement: outp_6_vehicle and reso_1/2/3/7/13_vehicle_1.
Their widths are sufficient to become the longitudinal axis. Swapping half-axes
and rotating by 90 or 270 degrees preserves the exact ground footprint while
meeting native six-metre width and ten-metre length requirements. That geometric
fact alone does not establish safe vehicle placement.

The sixth marker also references nonexistent resource_13. It lies in resource_10.
On 15 November the owner authorized best judgment on reconnecting it. The
diagnostic tests its unchanged geometry under reso_10_vehicle_1 at resource_10;
this association is explicit in source.json. The candidate addon now performs
this correction before native marker association, guarded by source position,
size, angle, shape, parent existence and destination-name availability.

The probe extracts source geometry and checks original dimensions and two
candidate orientations through native initSpawnPlaces. Each candidate gets a
four-second empty civilian-offroad and CSAT-MRAP physics probe. A clearance query,
damage, movement, displacement and uprightness are recorded. Parent sites use
their exact source rectangular boundaries. No player or Computer Use is involved.

Rejected preparations are retained:

- markers-dev1-rejected: extraction found resource_13 absent; the launcher still
  started an incomplete fixture. It was stopped. The launcher now checks required
  source files and extracted data before staging or launching.
- markers-dev2-rejected: a partial run used elliptical parent-site shapes instead
  of the upstream rectangles. It was stopped and the shape extraction guard added.

Neither attempt provides acceptance evidence.

- markers-dev3-rejected: all 24 physical probes were stable, but the clearance
  queries after the first vehicle at each site failed. The run is rejected.
- markers-dev4: the same probes add confirmed deletion and a one-second gap.
  All 24 clearance/physics checks pass, both candidate orientations produce one
  native slot, and corner comparison proves unchanged footprints. The six
  expected errors are original-geometry failures; no other errors are accepted.

These results support cleanup timing as the source of the earlier clearance
query failures. They cover four seconds per empty vehicle, not player driving,
long-term stability or all vehicle classes. The 90-degree option is used for
the candidate; it preserves the same area and passed both tested vehicle types.

The guarded addon passes 14 native-slot/idempotence/custom-data checks on Redux
and leaves Altis unchanged. Twelve collector tests pass. Full native Infection
campaign startup/save/process-restart/reload passes 13 assertions per phase,
including all six slots and the corrected resource-10 association. The two full
campaign reports remain failed on five writer and six reader records: startup/
object errors and a later helicopter-price error during background activity.
Population, loot-crate-price and parking-marker errors are absent. See Infection branch
`codex/redux-parking-validation`, `docs/research/REDUX_PARKING_VALIDATION.md`, and
`evidence/sprint-4/redux-companion-parking-*` for full evidence. No release gate
is closed by this source integration.
