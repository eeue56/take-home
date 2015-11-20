var configApi = function() {
    var loadConfig = function(){
        return function(fileName){
            return require(fileName);
        };
    };

    return {
        loadConfig, loadConfig
    }
}();

var make = function make(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Config = localRuntime.Native.Config || {};

    var Task = Elm.Native.Task.make(localRuntime);
    var List = Elm.Native.List.make(localRuntime);
    var Converters = Elm.Native.Converters.make(localRuntime);
    var jsObjectToElmDict = Converters.jsObjectToElmDict;

    if (localRuntime.Native.Config.values) {
        return localRuntime.Native.Config.values;
    }

    return {
        loadConfig: configApi.loadConfig(),
    };
};

Elm.Native.Config = {};
Elm.Native.Config.make = make;
