module Database.Nedb (Config, Client(..), Operation, UpdateOperation, createClient, createClientFromConfigFile, insert, find, update, actualLog) where

{-| Wrappers around Nedb for Node

@docs Config, Client, Operation

@docs createClient, createClientFromConfigFile

@docs insert

@docs find
-}

import Task exposing (Task)
import Native.Database.Nedb


{-| empty config
-}
type alias Config =
    {}


{-| standard client
-}
type Client
    = Client


type alias Operation a b =
    a -> Client -> Task String b


type alias UpdateOperation a b =
    a -> b -> Client -> Task String ()


{-| Create a client using the given record as an options object
-}
createClient : Config -> Client
createClient =
    Native.Database.Nedb.createClientConfig


{-| Create a client using the given filename for a json file
as an options object
-}
createClientFromConfigFile : String -> Client
createClientFromConfigFile =
    Native.Database.Nedb.createClientConfigFromConfigFile


{-| Insert documents into the client database

-}
insert : Operation a b
insert =
    Native.Database.Nedb.insert


{-|
    Takes a record with given fields and attempts to search for them
-}
find : Operation a (List b)
find =
    Native.Database.Nedb.find


{-| Update any matching records with the given record
-}
update : UpdateOperation a b
update =
    Native.Database.Nedb.update


{-| Use for low-level debugging to see how data is stored
-}
actualLog : a -> a
actualLog =
    Native.Database.Nedb.actualLog
