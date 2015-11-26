var TelateApi = function(){
    var loadObject = function(Just, Nothing) {
        return function(name){
            var obj = window[name];

            if (typeof obj === "undefined" || obj === null){
                return Nothing;
            }

            return Just(obj);
        };
    };

    return {
        loadObject: loadObject
    };

}();

var make = function make(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Telate = localRuntime.Native.Telate || {};

    if (localRuntime.Native.Telate.values) {
        return localRuntime.Native.Telate.values;
    }

    var Maybe = Elm.Maybe.make(localRuntime);

    var Nothing = Maybe.Nothing;
    var Just = Maybe.Just;

    return {
        'loadObject': TelateApi.loadObject(Just, Nothing)
    };
};

Elm.Native.Telate = {};
Elm.Native.Telate.make = make;
