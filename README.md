# A3U Redux Fixes

Independent compatibility fixes for Antistasi Ultimate on Chernarus Redux.
This is not an official Ultimate or Chernarus Redux release and has no Infection
or Zombies and Creatures dependency.

Development targets Ultimate 12.4.2 and Arma 3 2.22. Each fix requires a
reproduction, a focused check and full campaign startup evidence before release.
No release build is currently certified.

Initial confirmed issue: repeated native town initialization reads a previously
stored town-data array as a population number, then falls back to counting
houses. The intended fix preserves Ultimate's configured population values.
