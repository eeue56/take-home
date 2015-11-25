module User where

import Shared.User exposing (User, decoder)
import Database.Nedb as Database

import Task exposing (Task)
import Json.Decode as Json

{-|
Attempt to decode a list of json values into users
If any user fails to decode, drop it
-}
decodeUsers : List Json.Value -> List User
decodeUsers users =
    List.foldl
        (\user acc ->
            case Json.decodeValue decoder user of
                Ok actualUser -> actualUser :: acc
                Err _ -> acc)
        []
        users

{-| Get users from the database -}
getUsers : Database.Operation a (List User)
getUsers user database =
    Database.find user database
        |> Task.map decodeUsers

{-| Takes a record, returns true if any records in database
have matching fields
False otherwise
-}
alreadyExists : Database.Operation a Bool
alreadyExists user database =
    Database.find user database
        |> Task.map (not << List.isEmpty)

{-| Inserts a user into the database
-}
insertIntoDatabase : Database.Operation User String
insertIntoDatabase user client =
    Database.insert [user] client
