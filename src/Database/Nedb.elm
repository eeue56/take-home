module Database.Nedb where

import Task exposing (Task)

import Native.Database.Nedb

-- sadly, since nebd's options are all optional,
-- we just have to provide an empty record as a base
-- for createClient to take
type alias Config = { }

type Client =
    Client

type alias Operation a b =
    a -> Client -> Task String b

{-| Create a client using the given record as an options object
-}
createClient : Config -> Client
createClient =
    Native.Database.Nedb.createClient

{-| Create a client using the given filename for a json file
as an options object
-}
createClientFromConfigFile : String -> Client
createClientFromConfigFile =
    Native.Database.Nedb.createClientFromConfigFile

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
