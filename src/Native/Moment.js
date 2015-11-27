var MomentApi = function(Moment){
    var getCurrent = function(){
        return function(){
            return Moment().toObject();
        };
    };

    var format = function(){
        return function(moment) {
            return Moment(moment).format().toObject();
        };
    };

    var formatString = function(){
        return function(formatString, moment) {
            if (typeof formatString === "undefined" || formatString === null){
                return Moment(moment).format();
            }
            return Moment(moment).format(formatString);
        };
    };

    var add = function() {
        return function(first, second){
            var m = Moment(first);
            m.add(second);

            return m.toObject();
        };
    };

    var subtract = function() {
        return function(first, second){
            var m = Moment(first);
            m.subtract(second);

            return m.toObject();
        };
    };

    var from = function() {
        return function(first, second){
            var m = Moment(first);
            return m.from(Moment(second));
        };
    };

    var isBefore = function() {
        return function(first, second){
            var m = Moment(first);
            return m.isBefore(Moment(second));
        };
    };

    var isAfter = function() {
        return function(first, second){
            var m = Moment(first);
            return m.isAfter(Moment(second));
        };
    };

    return {
        getCurrent: getCurrent,
        format: format,
        formatString: formatString,
        add: add,
        subtract: subtract,
        from: from,
        isBefore: isBefore,
        isAfter: isAfter
    };

};

var make = function make(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Moment = localRuntime.Native.Moment || {};

    if (localRuntime.Native.Moment.values) {
        return localRuntime.Native.Moment.values;
    }

    var Moment = require('moment');
    var API = MomentApi(Moment);


    return {
        'getCurrent': API.getCurrent(),
        'formatString': F2(API.formatString()),
        'format': API.format(),
        'add': F2(API.add()),
        'subtract': F2(API.subtract()),
        'from': F2(API.from()),
        'isBefore': F2(API.isBefore()),
        'isAfter': F2(API.isAfter())
    };
};

Elm.Native.Moment = {};
Elm.Native.Moment.make = make;
