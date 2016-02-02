module Greenhouse where

import Task exposing (Task, andThen)
import Json.Encode exposing (Value(..))
import Native.Greenhouse


type alias PageIndex = Int

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
            |> (flip andThen) recurse

