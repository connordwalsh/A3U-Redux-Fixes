# RF-6: preserve empty HQ cargo without early missing-object errors

The official Redux mission's empty-string Eden cargo attribute removes two
backpacks from `boxX` during early initialization. The complete mission trace
identifies their IDs as the two remaining missing-object errors. An explicit
diagnostic control retaining inventory eliminates the errors, but would not
preserve intended HQ behavior. See `CRATE_OBJECT_DIAGNOSTIC.md` and Infection
PR 69 for the control evidence.

The candidate wrapper defers only that exact request until simulation time is
positive. It requires server locality, the official mission name, Redux terrain,
time zero, the original HQ crate class and source position, and an empty-string
inventory argument. A per-object flag prevents duplicate scheduled workers.
The worker exits if the crate is deleted or no longer local, then delegates
clearing to the installed native function using its explicit empty-cargo format.
The native source is not copied or redistributed.

Other missions, terrains, clients, later calls, custom cargo and inventory
queries delegate directly to the installed function. The correction changes
initialization timing, not the intended contents. It does not retain the stock
supplies or change the crate class.

Six focused checks pass on Redux and six on Altis: unrelated mission startup
is not deferred; its crate is empty; getter results match native; custom weapon,
magazine, item and backpack cargo is retained exactly; serialized cargo clears
normally; and runtime calls do not schedule a worker. Altis retains its known
native SmartMarker pre-init diagnostic, explicitly required by the collector;
it is not represented as an error-free terrain run.

The full campaign test additionally checks all four cargo categories and the
container list before JNA startup can clear them. Save/restart/reload results
are recorded in the Infection validation evidence. Connected-player, JIP and
manual playthrough checks remain open.
