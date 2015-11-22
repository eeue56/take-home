module User where

import Shared.User exposing (User, decoder)
import Database.Nedb as Database

import Task exposing (Task)
import Json.Decode as Json

decodeUsers : List Json.Value -> List User
decodeUsers users =
    List.foldl
        (\user acc ->
            case Json.decodeValue decoder user of
                Ok actualUser -> actualUser :: acc
                Err _ -> acc)
        []
        users

getUsers : Database.Operation a (List User)
getUsers user database =
    Database.find user database
        |> Task.map decodeUsers

alreadyExists : Database.Operation a Bool
alreadyExists user database =
    Database.find user database
        |> Task.map (not << List.isEmpty)

insertIntoDatabase : Database.Operation a String
insertIntoDatabase user client =
    Database.insert [user] client
