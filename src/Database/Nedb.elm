module Database.Nedb where


import Native.Database.Nedb

-- sadly, since nebd's options are all optional,
-- we just have to provide an empty record as a base
-- for createClient to take
type alias Config = { }

type Client =
    Client


createClient : Config -> Client
createClient =
    Native.Database.Nedb.createClient
