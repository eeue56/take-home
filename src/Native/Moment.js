var MomentApi = function(){
    var getCurrent = function(Moment){
        return function(){
            return Moment();
        };
    };

    var format = function(){
        return function(moment, formatString) {
            if (typeof formatString === "undefined" || formatString === null){
                return moment.format();
            }
            return moment.format(formatString);
        };
    };

    var dateDiff =  function(){
        return function(first, second){
            return first - second;
        };
    };

    return {
        getCurrent: getCurrent,
        format: format
    };

}();

var make = function make(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Moment = localRuntime.Native.Moment || {};

    if (localRuntime.Native.Moment.values) {
        return localRuntime.Native.Moment.values;
    }

    var moment = require('moment');


    return {
        'getCurrent': MomentApi.getCurrent(moment),
        'formatString': F2(MomentApi.format()),
        'format': MomentApi.format()
    };
};

Elm.Native.Moment = {};
Elm.Native.Moment.make = make;
