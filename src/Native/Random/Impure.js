var get = function(Task) {
    return function(_) {
        return Task.asyncFunction(function(callback){
            return callback(Task.succeed(Math.random()));
        });
    };
};

var make = function make(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Random = localRuntime.Native.Random || {};
    localRuntime.Native.Random.Impure = localRuntime.Native.Random.Impure || {};


    if (localRuntime.Native.Random.Impure.values) {
        return localRuntime.Native.Random.Impure.values;
    }

    var Task = Elm.Native.Task.make(localRuntime);

    return {
        get: get(Task)
    };
};

Elm.Native.Random = Elm.Native.Random || {};
Elm.Native.Random.Impure = {};
Elm.Native.Random.Impure.make = make;

if (typeof window === "undefined") {
    window = global;
}
