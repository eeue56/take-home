module User where

import Database.Nedb as Database
import Task exposing (Task)


getUsers : Database.Operation a (List b)
getUsers user database =
    Database.find user database

alreadyExists : Database.Operation a Bool
alreadyExists user database =
    Database.find user database
        |> Task.map (not << List.isEmpty)

insertIntoDatabase : Database.Operation a String
insertIntoDatabase user client =
    Database.insert [user] client
