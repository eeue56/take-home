module Knox (Config, createClient, putFile, urlify) where

{-| A module for performing operations using Knox, an API for
interacting with S3 storage.

@docs Config, createClient

@docs putFile

@docs urlify
-}

import Native.Knox
import Task exposing (Task)


type Client
    = Client


{-| Knox config takes a key, a secret and a bucket to use
-}
type alias Config =
    { key : String
    , secret : String
    , bucket : String
    }


{-| Create a Knox client from a given config
-}
createClient : Config -> Client
createClient =
    Native.Knox.createClient


{-| Upload a file with the given name to the given name
on the server using the given client. Returns a task
-}
putFile : String -> String -> Client -> Task a String
putFile =
    Native.Knox.putFile


{-| Run a string through Knox's internal url encoder
-}
urlify : String -> Client -> String
urlify =
    Native.Knox.urlify
