module Database.Nedb where

import Task exposing (Task)

import Native.Database.Nedb

-- sadly, since nebd's options are all optional,
-- we just have to provide an empty record as a base
-- for createClient to take
type alias Config = { }

type Client =
    Client


{-| Create a client using the given record as an options object
-}
createClient : Config -> Client
createClient =
    Native.Database.Nedb.createClient

{-| Insert documents into the client database

-}
insert : List a -> Client -> Task b String
insert =
    Native.Database.Nedb.insert
