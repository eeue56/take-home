module Bootstrapper where
{-|
This is a very naughty module indeed.

Swap out the two arguments to bootstrap with the name of your module
and the name of the output file.

That output file will then be ran whenever you call this script.

This script is also self-bootstrapping, simply run node on it and it will
handle the rest.

-}
import Native.Bootstrapper

bootstrap : String -> String -> ()
bootstrap =
    Native.Bootstrapper.bootstrap

port run : ()
port run =
    bootstrap "instance/server/Main" "instance/server/main.js"
