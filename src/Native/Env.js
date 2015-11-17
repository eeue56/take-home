var getEnv = function(jsObjectToElmDict) {
    return function() {
        return jsObjectToElmDict(process.env);
    };
};

var make = function make(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Env = localRuntime.Native.Env || {};


    if (localRuntime.Native.Env.values) {
        return localRuntime.Native.Env.values;
    }

    var Converters = Elm.Native.Converters.make(localRuntime);
    var jsObjectToElmDict = Converters.jsObjectToElmDict;

    return {
        getEnv: getEnv(jsObjectToElmDict)
    };
};

Elm.Native.Env = {};
Elm.Native.Env.make = make;

if (typeof window === "undefined") {
    window = global;
}
