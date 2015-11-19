
var knoxApi = function(){
    var knox = require('knox');

    function encodeSpecialCharacters(filename) {
      // Note: these characters are valid in URIs, but S3 does not like them for
      // some reason.
      return encodeURI(filename).replace(/[!'()#*+? ]/g, function (char) {
        return '%' + char.charCodeAt(0).toString(16);
      });
    }

    var createClient = function() {
        return function(config) {
            console.log(knox);
            return knox.createClient(config);
        };
    };

    var putFile = function(Task, Ok, Err) {
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

    var urlify = function() {
        return function(url, client){
            return client.http(url);
        };
    };

    return {
        putFile: putFile,
        createClient: createClient,
        urlify: urlify
    }
}();

var make = function make(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Knox = localRuntime.Native.Knox || {};


    if (localRuntime.Native.Knox.values) {
        return localRuntime.Native.Knox.values;
    }

    var Result = Elm.Result.make(localRuntime);
    var Task = Elm.Native.Task.make(localRuntime);

    return {
        createClient: knoxApi.createClient(),
        putFile: F3(knoxApi.putFile(Task, Result.Ok, Result.Err)),
        urlify: F2(knoxApi.urlify())
    };
};

Elm.Native.Knox = {};
Elm.Native.Knox.make = make;

if (typeof window === "undefined") {
    window = global;
}
