# Publication transport: live succeeds, numeric late-join value absent

Server PID 45776; headless client PID 46904. Server bound 127.0.0.1, client bound 127.0.0.2; loopback=0. This combination established the connection. Server and client both record owner 4, didJIP true, initial global value [11], initial numeric-excluded value []. Both record live values [33] and [44], and the server completes the fixture. The numeric -2 publication is therefore not a drop-in replacement for true: it loses initial data for this late joiner.

This run establishes transport behavior, not a garrison fix. Preserve JIP when designing replacement publication. Both exact process identities were checked before stopping, and absence was verified separately before archiving. No manual profile or production build changed.
