class CfgPatches {
    class A3URF_core {
        name = "A3U Redux Fixes";
        author = "A3U Redux Fixes contributors";
        requiredAddons[] = {"A3A_core", "A3_Missions_F_Oldman", "A3_Modules_F_Hc", "A3_Functions_F_Curator", "A3_3DEN"};
        requiredVersion = 2.22;
        units[] = {}; weapons[] = {};
        version = 0.1;
        A3A_compatibility[] = {12,4};
    };
};
class CfgFunctions {
    class A3URF {
        tag = "A3URF";
        class Compatibility {
            class originalGarrisonUpdate { file = "\x\a3a\addons\core\functions\CREATE\fn_garrisonUpdate.sqf"; };
            class originalGetCityData { file = "\x\a3a\addons\core\functions\init\fn_getCityData.sqf"; };
            class originalVehiclePrice { file = "\x\a3a\addons\core\functions\REINF\fn_vehiclePrice.sqf"; };
            class originalPrepareMarkerArrays { file = "\x\a3a\addons\core\functions\init\fn_prepareMarkerArrays.sqf"; };
            class originalSmartMarkers { file = "\a3\Missions_F_Oldman\Systems\scripts\SmartMarkers\fn_OM_moduleSmartMarkers.sqf"; };
            class repairParkingMarkers { file = "\x\a3urf\addons\core\fn_repairParkingMarkers.sqf"; };
            class initHighCommand { file = "\x\a3urf\addons\core\fn_initHighCommand.sqf"; };
            class originalActivateAddons { file = "\A3\functions_f_curator\Misc\fn_activateAddons.sqf"; };
            class originalInitAmmoBox { file = "\A3\3DEN\Functions\fn_initAmmoBox.sqf"; };
        };
    };
    class A3A {
        class CREATE {
            class garrisonUpdate { file = "\x\a3urf\addons\core\fn_garrisonUpdate.sqf"; };
        };
        class init {
            class getCityData { file = "\x\a3urf\addons\core\fn_getCityData.sqf"; };
            class prepareMarkerArrays { file = "\x\a3urf\addons\core\fn_prepareMarkerArrays.sqf"; };
        };
        class REINF {
            class vehiclePrice { file = "\x\a3urf\addons\core\fn_vehiclePrice.sqf"; };
        };
    };
    class A3_Oldman {
        class SmartMarkers {
            class OM_moduleSmartMarkers { file = "\x\a3urf\addons\core\fn_smartMarkers.sqf"; };
        };
    };
    class A3_Functions_F_Curator {
        class Misc {
            class activateAddons { file = "\x\a3urf\addons\core\fn_activateAddons.sqf"; };
        };
    };
    class 3DEN {
        class Default {
            class initAmmoBox { file = "\x\a3urf\addons\core\fn_initAmmoBox.sqf"; };
        };
    };
};
class CfgVehicles {
    class Module_F;
    class HighCommand: Module_F {
        class EventHandlers {
            init = "_this call A3URF_fnc_initHighCommand";
        };
    };
};
