var createClient = function(knox) {
    return function(config) {
        return knox.createClient(config);
    };
};

var putFile = function(knox, Task, Ok, Err) {
    return function(localFileName, serverFileName, client){

        return Task.asyncFunction(function(callback){
            client.putFile(localFileName, serverFileName, function(err, res){
                if (err){
                    return callback(Task.succeed(Err("Failed to upload!")));
                }
                res.resume();
                return callback(Task.succeed(Ok("File uploaded")));
            });
        });
    };
};

var make = function make(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Knox = localRuntime.Native.Knox || {};


    if (localRuntime.Native.Knox.values) {
        return localRuntime.Native.Knox.values;
    }

    var knox = require('knox');
    var Result = Elm.Result.make(localRuntime);
    var Task = Elm.Native.Task.make(localRuntime);


    return {
        createClient: createClient(knox),
        putFile: F3(putFile(knox, Task, Result.Ok, Result.Err))
    };
};

Elm.Native.Knox = {};
Elm.Native.Knox.make = make;

if (typeof window === "undefined") {
    window = global;
}
