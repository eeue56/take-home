var RecordApi = function(){
    var asDict = function(jsObjectToElmDict) {
        return jsObjectToElmDict;
    };

    return {
        asDict: asDict
    };

}();

var make = function make(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Record = localRuntime.Native.Record || {};

    if (localRuntime.Native.Record.values) {
        return localRuntime.Native.Record.values;
    }

    var Converters = Elm.Native.Converters.make(localRuntime);

    return {
        'asDict': RecordApi.asDict(Converters.jsObjectToElmDict)
    };
};

Elm.Native.Record = {};
Elm.Native.Record.make = make;
