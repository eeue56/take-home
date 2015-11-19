var v1 = function(uuid, Task){
    return function(){
        return Task.asyncFunction(function (callback) {
            return callback(Task.succeed(uuid.v1()));
        });
    };
};

var v4 = function(uuid, Task){
    return function(){
        return Task.asyncFunction(function (callback) {
            return callback(Task.succeed(uuid.v4()));
        });
    };
};

var make = function make(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Uuid = localRuntime.Native.Uuid || {};


    if (localRuntime.Native.Uuid.values) {
        return localRuntime.Native.Uuid.values;
    }

    var stashedWindow = global.window;
    global.window = undefined;
    var uuid = require('node-uuid');
    global.window = stashedWindow;


    var Task = Elm.Native.Task.make(localRuntime);

    return {
        'v1': v1(uuid, Task),
        'v4': v4(uuid, Task)
    };
};

Elm.Native.Uuid = {};
Elm.Native.Uuid.make = make;
