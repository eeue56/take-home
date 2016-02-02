var createUrl = function(basePath, page, perPage){
    return basePath + "?page=" + page + "&per_page=" + perPage;
};

var get = function(Task, Tuple2, fromArray, parseHeader, https) {
    return function(authToken, url, pageNumber, perPage) {

        var url = createUrl(url, pageNumber, perPage);
        console.log(url)

        var options = {
            host: "harvest.greenhouse.io",
            path: url,
            auth: authToken + ':'
        };

        return Task.asyncFunction(function(callback){
            https.get(options, function(response){
                var str = '';

                response.on('data', function (chunk) {
                    str += chunk;
                });

                response.on('end', function () {
                    var asJson = JSON.parse(str);
                    var linked = parseHeader(response.headers.link);
                    console.log(asJson);
                    var array = fromArray(asJson);
                    console.log(array);
                    callback(
                        Task.succeed(
                            Tuple2(array, parseInt(linked.last.page))
                        )
                    );
                });

                response.on('error', function(err){
                    callback(Task.fail(err.message));
                });
            });
        });
    };
};

var make = function make(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Greenhouse = localRuntime.Native.Greenhouse || {};


    if (localRuntime.Native.Greenhouse.values) {
        return localRuntime.Native.Greenhouse.values;
    }

    var Task = Elm.Native.Task.make(localRuntime);
    var Utils = Elm.Native.Utils.make(localRuntime);
    var Tuple2 = Utils['Tuple2'];
    var List = Elm.Native.List.make(localRuntime);



    var https = require('https');
    var parseHeader = require('parse-link-header');

    return {
        get: F4(get(Task, Tuple2, List.fromArray, parseHeader, https))
    };
};

Elm.Native.Greenhouse = {};
Elm.Native.Greenhouse.make = make;

if (typeof window === "undefined") {
    window = global;
}
