if (!isServer) exitWith {};
[] spawn {
 sleep 3;
 diag_log format ["[REDUX_CRATE_PLACED] %1",["after",typeOf boxX,netId boxX,
  everyContainer boxX apply {[_x select 0,netId (_x select 1)]},getBackpackCargo boxX]];
 diag_log "[REDUX_CRATE_PLACED] complete";
};
