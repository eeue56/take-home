
function encodeSpecialCharacters(filename) {
  // Note: these characters are valid in URIs, but S3 does not like them for
  // some reason.
  return encodeURI(filename).replace(/[!'()#*+? ]/g, function (char) {
    return '%' + char.charCodeAt(0).toString(16);
  });
}

var createClient = function(knox) {
    return function(config) {
        return knox.createClient(config);
    };
};

var putFile = function(knox, Task, Ok, Err) {
    return function(localFileName, serverFileName, client){
        return Task.asyncFunction(function(callback){
            client.putFile(
                localFileName,
                encodeSpecialCharacters(serverFileName),
                { 'x-amz-acl': 'public-read' },
                function(err, res){
                    if (err){
                        return callback(Task.succeed(Err("Failed to upload!")));
                    }
                    res.resume();

                    return callback(
                        Task.succeed(
                            urlify(knox)(serverFileName, client)
                        )
                    );
                }
            );
        });
    };
};

var urlify = function(knox) {
    return function(url, client){
        return client.http(url);
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
        putFile: F3(putFile(knox, Task, Result.Ok, Result.Err)),
        urlify: F2(urlify(knox))
    };
};

Elm.Native.Knox = {};
Elm.Native.Knox.make = make;

if (typeof window === "undefined") {
    window = global;
}
