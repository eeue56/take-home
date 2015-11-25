
var bootstrap = function(fs, exec, compiler){
    var compile = function(file, outFile, onClose){
        compiler.compile([file + '.elm'], {
            output: outFile,
            yes: true
        }).on('close', onClose);
    };

    return function(filename, output){
        console.log("here");
        compile(filename, output, function(){
            var dirIndex = filename.lastIndexOf('/');
            var lastFileName = filename.substr(dirIndex + 1);

            fs.appendFileSync(output, "\nElm.worker(Elm." + lastFileName + ");")
            var child = exec('node ' + output);

            child.stdout.on('data', console.log);
            child.stderr.on('data', console.error);
            child.on('close', function(code) {
                console.log('closing code: ' + code);
            });
        });
    };
};

var make = function make(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Bootstrapper = localRuntime.Native.Bootstrapper || {};

    if (localRuntime.Native.Bootstrapper.values) {
        return localRuntime.Native.Bootstrapper.values;
    }
    var fs = require('fs');
    var exec = require('child_process').exec;
    var compiler = require('node-elm-compiler');


    return {
        bootstrap: F2(bootstrap(fs, exec, compiler))
    };
};

Elm.Native.Bootstrapper = {};
Elm.Native.Bootstrapper.make = make;

if (typeof window === "undefined") {
    window = global;
}

setTimeout(function() {
    console.log("starting elm..");
    Elm.worker(Elm.Bootstrapper);
}, 1000);
