module Knox where

import Native.Knox
import Task exposing (Task)

type Client = Client

type alias Config =
    { key: String
    , secret: String
    , bucket: String
    }

createClient : Config -> Client
createClient =
    Native.Knox.createClient

putFile : String -> String -> Client -> Task a String
putFile =
    Native.Knox.putFile

urlify : String -> Client -> String
urlify =
    Native.Knox.urlify
