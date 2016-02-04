module Greenhouse where

import Task exposing (Task)
import Json.Decode exposing (..)
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


get : String -> String -> PageIndex -> Int -> Task String (List Value, PageIndex)
get authToken url pageNumber numberPerPage =
    Native.Greenhouse.get authToken url pageNumber numberPerPage


getUsers : String -> PageIndex -> Int -> Task String (List Value)
getUsers authToken pageNumber numberPerPage =
    let
        nextPageNumber =
            pageNumber + 1

        recurse : (List Value, PageIndex) -> Task String (List Value)
        recurse (users, endNumber) =
            if endNumber == pageNumber then
                Task.succeed users
            else
                Task.map (\newUsers -> newUsers ++ users) (getUsers authToken nextPageNumber numberPerPage)

    in
        get authToken "/v1/candidates" pageNumber numberPerPage
            |> (flip Task.andThen) recurse

