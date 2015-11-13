var COMPILED_DIR = '.comp';

// take a name as a string, return an elm object of the type
// the name given
var wrap_with_type = function(item){
    return {
        ctor: item
    };
};

// make the directory for compiled Elm code
var make_compile_dir = function(fs, dir){
    if (typeof dir === "undefined"){
        dir = COMPILED_DIR;
    }

    if (!fs.existsSync(dir)){
       fs.mkdirSync(dir);
    }
};

var createServer = function createServer(fs, http, Tuple2, Task) {
    return function (address) {
        make_compile_dir(fs, __dirname + "/" + COMPILED_DIR);

        var send = address._0;
        var server = http.createServer(function (request, response) {
            request.method = wrap_with_type(request.method);
            return Task.perform(send(Tuple2(request, response)));
        });
        return Task.asyncFunction(function (callback) {
            return callback(Task.succeed(server));
        });
    };
};

var listen = function listen(Task) {
    return function (port, echo, server) {
        return Task.asyncFunction(function (callback) {
            return server.listen(port, function () {
                console.log(echo);
                return callback(Task.succeed(server));
            });
        });
    };
};

var on = function on(Signal) {
    return function (eventName, x) {
        return x.on(eventName, function (request, response) {
            if (typeof(request) == 'undefined') {
                return Signal.input(eventName, Tuple0);
            }
            return Signal.input(eventName, Tuple(request, response));
        });
    };
};
var make = function make(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Http = localRuntime.Native.Http || {};


    if (localRuntime.Native.Http.values) {
        return localRuntime.Native.Http.values;
    }

    var http = require('http');
    var fs = require('fs');
    var mime = require('mime');

    var Task = Elm.Native.Task.make(localRuntime);
    var Utils = Elm.Native.Utils.make(localRuntime);
    var Signal = Elm.Native.Signal.make(localRuntime);
    var Tuple0 = Utils['Tuple0'];
    var Tuple2 = Utils['Tuple2'];

    return {
        'createServer': createServer(fs, http, Tuple2, Task),
        'listen': F3(listen(Task)),
        'on': F2(on(Signal, Tuple0))
    };
};
Elm.Native.Http = {};
Elm.Native.Http.make = make;

if (typeof window === "undefined") {
    window = global;
}
