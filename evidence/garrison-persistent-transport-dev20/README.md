# Persistent remote delivery transport control

The first late-joining client (owner 4) receives remote_value [55], then the live replacement [66]. The server retains its deliberately newer local value [77], demonstrating that excluded-server delivery does not overwrite it. A second fresh client (owner 5) joins after the first disconnects and receives [66], proving replacement of the same persistent entry. Numeric -2 setVariable remains absent for the second joiner, as expected from Dev18.

This is a transport experiment, not acceptance of a garrison patch. Ultimate has direct roster writers beyond garrisonUpdate. A stored snapshot must not override a later native capture, reset, load, or reinforcement when a client joins. Integration must account for these writers or request current authoritative state on joining.

Server PID 10216, first client 46188, second client 15628 were individually checked before stopping; all absences verified. No production build or manual profile changed.
