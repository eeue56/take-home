var databaseApi = function(Database) {
    var createClient = function() {
        return function(config) {
            return new Database(config);
        };
    };

    return {
        createClient: createClient
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


    if (localRuntime.Native.Database.Nedb.values) {
        return localRuntime.Native.Database.Nedb.values;
    }


    return {
        createClient: nedbApi.createClient()
    };
};

Elm.Native.Database = {};
Elm.Native.Database.Nedb = {};
Elm.Native.Database.Nedb.make = make;
