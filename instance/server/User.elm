module User where

import Database.Nedb as Database
import Task exposing (Task)

getUser : a -> Database.Client -> Task String (List b)
getUser user database =
    Database.find user database

alreadyExists : a -> Database.Client -> Task String Bool
alreadyExists user database =
    Database.find user database
        |> Task.map (not << List.isEmpty)

insertIntoDatabase : a -> Database.Client -> Task String String
insertIntoDatabase user client =
    Database.insert [user] client
