class CfgPatches {
    class A3URF_core {
        name = "A3U Redux Fixes";
        author = "A3U Redux Fixes contributors";
        requiredAddons[] = {"A3A_core"};
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
            class originalGetCityData { file = "\x\a3a\addons\core\functions\init\fn_getCityData.sqf"; };
        };
    };
    class A3A {
        class init {
            class getCityData { file = "\x\a3urf\addons\core\fn_getCityData.sqf"; };
        };
    };
};
