var jsObjectToElmDict = function(toList, Tuple2, Dict){
    return function(obj){
        var keyPair = [];
        var keys = Object.keys(obj);

        for (var i = 0; i < keys.length; i++){
            var key = keys[i];
            var value = obj[key];

            keyPair.push(Tuple2(key, value));
        }

        return Dict.fromList(toList(keyPair));
    };
};

var deserialize = function(){
    return function(a){
        return a;
    };
};

var make = function make(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Converters = localRuntime.Native.Converters || {};

    if (localRuntime.Native.Converters.values) {
        return localRuntime.Native.Converters.values;
    }

    var Utils = Elm.Native.Utils.make(localRuntime);
    var Tuple2 = Utils['Tuple2'];
    var List = Elm.Native.List.make(localRuntime);
    var Dict = Elm.Dict.make(localRuntime);

    return {
        jsObjectToElmDict: jsObjectToElmDict(List.fromArray, Tuple2, Dict),
        deserialize: deserialize()
    };
};

Elm.Native.Converters = {};
Elm.Native.Converters.make = make;

if (typeof window === "undefined") {
    window = global;
}
