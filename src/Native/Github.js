var createIssue = function(githubApi, Tuple0, Task) {
    return function(auth, session, settings) {
        return Task.asyncFunction(function(callback){
            var github = new githubApi(auth);
            github.authenticate(session);
            github.issues.create(settings, function(err, data){
                if (err){
                    callback(Task.fail(err));
                }

                callback(Task.succeed(Tuple0));
            });
        });
    };
};

var make = function make(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Github = localRuntime.Native.Github || {};


    if (localRuntime.Native.Github.values) {
        return localRuntime.Native.Github.values;
    }

    var githubApi = require('github');

    var Utils = Elm.Native.Utils.make(localRuntime);
    var Task = Elm.Native.Task.make(localRuntime);

    return {
        createIssue: F3(createIssue(githubApi, Utils['Tuple0'], Task))
    };
};

Elm.Native.Github = {};
Elm.Native.Github.make = make;

if (typeof window === "undefined") {
    window = global;
}
