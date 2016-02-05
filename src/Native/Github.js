var createSession = function(githubApi){
    return function(session) {
        var github = new githubApi(session);

        console.log("github", github);

        return {
            ctor : 'Session',
            github: github
        };
    };
};

var authenticate = function(){
    return function(auth, session) {
        session.github.authenticate(auth);
        return session;
    };
};

var createIssue = function(Tuple0, Task) {
    return function(settings, session) {
        return Task.asyncFunction(function(callback){
            session.github.issues.create(settings, function(err, data){
                if (err){
                    callback(Task.fail(err));
                }

                callback(Task.succeed(Tuple0));
            });
        });
    };
};

var getTeams = function(Task, List) {
    return function(settings, session) {
        return Task.asyncFunction(function(callback){
            session.github.orgs.getTeams(settings, function(err, data){
                if (err){
                    callback(Task.fail(err));
                }

                // hacks to ignore the meta properties
                var teams = data.map(function(v){
                    return v;
                });

                callback(Task.succeed(List.fromArray(teams)));
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

    var List = Elm.Native.List.make(localRuntime);
    var Utils = Elm.Native.Utils.make(localRuntime);
    var Task = Elm.Native.Task.make(localRuntime);

    return {
        createSession: createSession(githubApi),
        authenticate: F2(authenticate()),
        createIssue: F2(createIssue(Utils['Tuple0'], Task)),
        getTeams: F2(getTeams(Task, List))
    };
};

Elm.Native.Github = {};
Elm.Native.Github.make = make;

if (typeof window === "undefined") {
    window = global;
}
