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

    var add = function(Moment) {
        return function(first, second){
            var m = Moment(second);
            m.add(first);

            return m;
        };
    };

    var subtract = function(Moment) {
        return function(first, second){
            var m = Moment(second);
            m.subtract(first);

            return m;
        };
    };

    var toRecord = function(){
        return function(moment) {
            return moment.toObject();
        };
    };

    var fromRecord = function(Moment) {
        return function(moment){
            return Moment(moment);
        };
    };

    return {
        getCurrent: getCurrent,
        format: format,
        add: add,
        subtract: subtract,
        toRecord: toRecord,
        fromRecord: fromRecord
    };

}();

var make = function make(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Moment = localRuntime.Native.Moment || {};

    if (localRuntime.Native.Moment.values) {
        return localRuntime.Native.Moment.values;
    }

    var Moment = require('moment');


    return {
        'getCurrent': MomentApi.getCurrent(Moment),
        'formatString': F2(MomentApi.format()),
        'format': MomentApi.format(),
        'add': F2(MomentApi.add(Moment)),
        'subtract': F2(MomentApi.subtract(Moment)),
        'toRecord': MomentApi.toRecord(),
        'fromRecord': MomentApi.fromRecord(Moment)
    };
};

Elm.Native.Moment = {};
Elm.Native.Moment.make = make;
