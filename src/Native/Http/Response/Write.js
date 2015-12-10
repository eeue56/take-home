var buffertools = require('buffertools');

var COMPILED_DIR = '.comp';

var writeHead = function writeHead(Task) {
    return function (code, header, res) {
        var o = {};
        return Task.asyncFunction(function (callback) {
            o[header._0] = header._1;
            res.writeHead(code, o);
            return callback(Task.succeed(res));
        });
    };
};

var write = function write(Task) {
    return function (message, res) {
        return Task.asyncFunction(function (callback) {
            res.write(message);
            return callback(Task.succeed(res));
        });
    };
};

var writeFile = function writeFile(fs, mime, Task){
    return function (fileName, res) {
        return Task.asyncFunction(function (callback) {
            var file = __dirname + fileName;
            var type = mime.lookup(file);

            res.writeHead('Content-Type', type);

            fs.readFile(file, function (e, data) {
                if (e !== null && e.code == 'ENOENT'){
                    res.writeHead(404);
                    return callback(Task.fail("404"));
                }
                res.write(data);

                return callback(Task.succeed(res));
            });

        });
    };
};

var writeElm = function writeElm(fs, mime, crypto, compiler, Task){

    var compile = function(file, outFile, onClose){
        // switch to the directory that the elm-app is served out of

        //var dirIndex = file.lastIndexOf('/');
        //var dir = file.substr(0, dirIndex);
        //process.chdir(dir);

        compiler.compile([file + '.elm'], {
            output: outFile,
            yes: true
        }).on('close', onClose);
    };

    return function (fileName, appendable, res) {
        var compiledFile = COMPILED_DIR + fileName + '.html';

        if (typeof appendable !== "undefined"){
            if (appendable.ctor === "Nothing"){
                appendable = null;
            } else {
                var name = appendable._0.name;
                var val = appendable._0.val;
                appendable = "var " + name + " = " + JSON.stringify(val);
            }
        }

        // if the file is already compiled, just send it out
        if (fs.existsSync(compiledFile)) {
            console.log("already compiled");
            return writeFile(fs, mime, Task)("/" + compiledFile, res, appendable);
        }

        return Task.asyncFunction(function (callback) {
            var file = __dirname + fileName;
            var outFile = __dirname + "/" + compiledFile;

            // when the file is compiled, attempt to send it out
            var onClose = function(exitCode) {
                var type = mime.lookup(file + '.html');
                res.writeHead('Content-Type', type);

                fs.readFile(outFile, function (e, data) {
                    var headClose = buffertools.indexOf(data, "</head>");
                    var outData = data;
                    if (!(typeof appendable === "undefined" || appendable === null)){
                        var extra = new Buffer("<script>" + appendable + "</script>");
                        outData = new Buffer(extra.length + data.length);

                        //outData = Buffer.concat(data.slice(0, headClose), extra, data.slice(headClose, ))
                        outData.write(data.slice(0, headClose).toString());
                        outData.write(extra.toString(), headClose);
                        outData.write(data.slice(headClose).toString(), headClose + extra.length);
                    }

                    res.write(outData);


                    return callback(Task.succeed(res));
                });
            };

            compile(file, outFile, onClose);
        });
    };
};

var writeNode = function writeNode(toHtml, Task){
    return function(node, res) {
        return write(Task)(toHtml(node), res);
    };
};

var end = function end(Task, Tuple0) {
    return function (res) {
        return Task.asyncFunction(function (callback) {
            return (function () {
                res.end();
                return callback(Task.succeed(Tuple0));
            })();
        });
    };
};

var make = function make(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Http = localRuntime.Native.Http || {};
    localRuntime.Native.Http.Response = localRuntime.Native.Http.Response || {};
    localRuntime.Native.Http.Response.Write = localRuntime.Native.Http.Response.Write || {};

    if (localRuntime.Native.Http.Response.Write.values) {
        return localRuntime.Native.Http.Response.Write.values;
    }

    var fs = require('fs');
    var crypto = require('crypto');

    var mime = require('mime');
    var compiler = require('node-elm-compiler');
    var toHtml = require('vdom-to-html');

    var Task = Elm.Native.Task.make(localRuntime);
    var Utils = Elm.Native.Utils.make(localRuntime);
    var Tuple0 = Utils['Tuple0'];


    return {
        'writeHead': F3(writeHead(Task)),
        'writeFile': F2(writeFile(fs, mime, Task)),
        'writeElm': F3(writeElm(fs, mime, crypto, compiler, Task)),
        'writeNode': F2(writeNode(toHtml, Task)),
        'write': F2(write(Task)),
        'toHtml': toHtml,
        'end': end(Task, Tuple0)
    };
};

Elm.Native = Elm.Native || {};
Elm.Native.Http = Elm.Native.Http || {};
Elm.Native.Http.Response = Elm.Native.Http.Response || {};
Elm.Native.Http.Response.Write = Elm.Native.Http.Response.Write || {};
Elm.Native.Http.Response.Write.make = make;

if (typeof window === "undefined") {
    window = global;
}
