var databaseApi = function(Database) {
    var createClient = function() {
        return function(config) {
            return new Database(config);
        };
    };

    var insert = function(toArray, Task) {
        return function(docsCollection, client) {
            var docs = toArray(docsCollection);

            return Task.asyncFunction(function(callback){
                client.insert(docs, function(err, newDoc){
                    if (err){
                        return callback(Task.fail("failed to insert doc"));
                    }

                    return callback(Task.succeed(newDoc._id));
                });
            });
        };
    };

    return {
        createClient: createClient,
        insert: insert
    }
};

var nedbApi = function() {
    var Database = require('nedb');

    return databaseApi(Database);
}();

var make = function make(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Database = localRuntime.Native.Database || {};
    localRuntime.Native.Database.Nedb = localRuntime.Native.Database.Nedb || {};

    var Task = Elm.Native.Task.make(localRuntime);
    var List = Elm.Native.List.make(localRuntime);

    if (localRuntime.Native.Database.Nedb.values) {
        return localRuntime.Native.Database.Nedb.values;
    }

    return {
        createClient: nedbApi.createClient(),
        insert: F2(nedbApi.insert(List.toArray, Task))
    };
};

Elm.Native.Database = {};
Elm.Native.Database.Nedb = {};
Elm.Native.Database.Nedb.make = make;
