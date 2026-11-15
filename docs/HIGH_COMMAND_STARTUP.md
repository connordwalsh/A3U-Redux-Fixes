# RF-3: defer empty High Command startup on Redux

Ultimate disables unoccupied AI slots. On a dedicated Redux server with no
players, commanderX is absent and the main High Command scope is synchronized
only to its subordinate. The installed native HC script nevertheless bypasses
its synchronization wait for the main scope and uses a nonexistent leader.
Paired diagnostics and a read-only full campaign snapshot confirm this state.

The Redux compatibility initializer preserves the native main-scope assignment,
then waits at 0.25-second intervals for a non-subordinate synchronized object.
Once present, it runs the installed native HC script without replacing its
group assignment, MARTA setup or client initialization. Repeated initialization
does not create another worker. Deleting a waiting scope terminates its worker.
Other worlds and Eden delegate to native startup immediately.

This follows Ultimate's existing commander-transfer path, which synchronizes
the newly appointed commander to HC_commanderX. No dummy commander is created.
The addon explicitly depends on the installed HC module for configuration order.

## Evidence

- `hc-logging-dev1`: with function logging enabled, native late-created HC binds
  a commander both with automatic MARTA creation and with MARTA already present.
  Neither reproduces the full campaign's addon-activation error. This does not
  prove that MARTA is its cause, and production MARTA behavior was not changed.
- `hc-deferred-dev1`: eight assertions verify waiting without a commander,
  duplicate protection, late leader binding, native script completion, exactly
  one MARTA module, preserved main scope, a second pending scope and worker
  termination after deletion. No error records occur.
- `hc-ready-dev1`: an immediately synchronized commander binds normally with
  function logging enabled and no error records.
- `hc-altis-dev1`: native leader binding still succeeds outside Redux.

Complete RPTs, launch identities, strict parsed reports and build manifests are
preserved. The HC collectors now detect uppercase ERROR as well. All 28
independent evidence tests pass. Bohemia source is read from the installation,
not copied into this repository or distributed in the addon.

Full native Infection campaign write/process-restart/read each pass 17 assertions
and 75-second background windows. The real empty HC scope waits safely while
campaign startup, saving and loading proceed. Missing-leader errors are absent;
two missing-object errors and an addon-init error still fail clean-log acceptance.
The latter occurs before the deferred HC script runs, separating it from this
failure. See Infection's `docs/research/REDUX_HC_VALIDATION.md` and retained
`redux-companion-hc-*` evidence. Eight campaign collector/parser tests pass.

A server-side AI commander exercises synchronization, not connected-player UI
or JIP. Those gates and release readiness remain open. No Computer Use or
manual-install modifications occurred.
