module Greenhouse where

import Task exposing (Task)
import Json.Decode as Json exposing (..)
import Json.Decode.Extra exposing (apply, (|:))
import Native.Greenhouse


type alias PageIndex = Int

type alias User =
    { id : String
    , firstName : String
    , lastName : String
    , applicationIds : List Int
    }



userDecoder =
    succeed User
        |: ("token" := string)
        |: ("name" := string)
        |: ("email" := string)
        |: ("role" := list int)


{-|
Attempt to decode a list of json values into users
If any user fails to decode, drop it
-}
decodeUsers : List Json.Value -> List User
decodeUsers users =
    List.foldl
        (\user acc ->
            case Json.decodeValue userDecoder user of
                Ok actualUser ->
                    actualUser :: acc

                Err _ ->
                    acc
        )
        []
        users


get : String -> String -> PageIndex -> Int -> Task String (List Value, PageIndex)
get authToken url pageNumber numberPerPage =
    Native.Greenhouse.get authToken url pageNumber numberPerPage


getUsers : String -> PageIndex -> Int -> Task String (List User)
getUsers authToken pageNumber numberPerPage =
    let
        nextPageNumber =
            pageNumber + 1

        recurse : (List User, PageIndex) -> Task String (List User)
        recurse (users, endNumber) =
            if endNumber == pageNumber then
                Task.succeed users
            else
                Task.map (\newUsers -> newUsers ++ users) (getUsers authToken nextPageNumber numberPerPage)

    in
        get authToken "/v1/candidates" pageNumber numberPerPage
            |> (flip Task.andThen) (\(users, index) -> recurse (decodeUsers users, index) )

