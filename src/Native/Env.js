var getEnv = function(jsObjectToElmDict, Task) {
    return function() {
        return Task.asyncFunction(function(callback){
            return callback(Task.succeed(jsObjectToElmDict(process.env)));
        });
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
    var Task = Elm.Native.Task.make(localRuntime);

    return {
        getEnv: getEnv(jsObjectToElmDict, Task)
    };
};

Elm.Native.Env = {};
Elm.Native.Env.make = make;

if (typeof window === "undefined") {
    window = global;
}
