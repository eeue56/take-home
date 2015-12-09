var databaseApi = function(Database) {
    var loadConfig = function(jsObjectToElmDict, Task){
        return function(fileName){
            return Task.asyncFunction(function(callback){

                try {
                    var config = require(fileName);
                } catch (err) {
                    return callback(Task.fail("Failed to load file: " + fileName));
                }

                return callback(
                    Task.succeed(
                        jsObjectToElmDict(config)
                    )
                );
            });
        };
    };

    var createClient = function() {
        return function(config) {
            return new Database(config);
        };
    };

    var createClientFromConfigFile = function() {
        return function(fileName) {
            var config = require(fileName);
            return new Database(config);
        };
    };

    // note: insert will timeout if you haven't first called loadDatabase!
    // not really much I can do about this
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

    var find = function(toArray, toList, Task) {
        return function(queryRecord, client){
            return Task.asyncFunction(function(callback){
                client.find(queryRecord, function(err, docs){
                    if (err){
                        return callback(Task.fail("Failed to find any matches"));
                    }

                    return callback(Task.succeed(toList(docs)));
                });
            })
        };
    };

    var update = function(Task) {
        return function(queryRecord, replacement, client){

            return Task.asyncFunction(function(callback){
                client.update(queryRecord, replacement, function(err, docs){
                    if (err){
                        console.log("err", err);
                        return callback(Task.fail("Failed to find any matches"));
                    }

                    return callback(Task.succeed([]));
                });
            })
        };
    };

    return {
        loadConfig: loadConfig,
        createClient: createClient,
        createClientFromConfigFile: createClientFromConfigFile,
        insert: insert,
        find: find,
        update: update,
        actualLog: console.log
    };
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
    var Converters = Elm.Native.Converters.make(localRuntime);
    var jsObjectToElmDict = Converters.jsObjectToElmDict;

    if (localRuntime.Native.Database.Nedb.values) {
        return localRuntime.Native.Database.Nedb.values;
    }

    return {
        loadConfig: nedbApi.loadConfig(jsObjectToElmDict, Task),
        createClient: nedbApi.createClient(),
        createClientFromConfigFile: nedbApi.createClientFromConfigFile(),
        insert: F2(nedbApi.insert(List.toArray, Task)),
        find: F2(nedbApi.find(List.toArray, List.fromArray, Task)),
        update: F3(nedbApi.update(Task)),
        actualLog: nedbApi.actualLog
    };
};

Elm.Native.Database = {};
Elm.Native.Database.Nedb = {};
Elm.Native.Database.Nedb.make = make;
