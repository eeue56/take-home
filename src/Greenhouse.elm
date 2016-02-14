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


type alias Job =
    { id : Int
    , name : String
    }



type alias Application =
    { id : Int
    , candidateId : Int
    , prospect : Bool
    , status : String
    , jobs : List Job
    }

userDecoder : Decoder User
userDecoder =
    succeed User
        |: ("token" := string)
        |: ("name" := string)
        |: ("email" := string)
        |: ("role" := list int)

jobDecoder : Decoder Job
jobDecoder =
    succeed Job
        |: ("id" := int)
        |: ("name" := string)

applicationDecoder : Decoder Application
applicationDecoder =
    succeed Application
        |: ("id" := int)
        |: ("candidateId" := int)
        |: ("prospect" := bool)
        |: ("status" := string)
        |: ("jobs" := list jobDecoder)


tolerantDecodeAll : Decoder a -> List Json.Value -> List a
tolerantDecodeAll decoder items =
    List.foldl
        (\item acc ->
            case Json.decodeValue decoder item of
                Ok actualItem ->
                    actualItem :: acc

                Err _ ->
                    acc
        )
        []
        items

{-|
Attempt to decode a list of json values into users
If any user fails to decode, drop it
-}
decodeUsers : List Json.Value -> List User
decodeUsers =
    tolerantDecodeAll userDecoder

decodeApplications : List Json.Value -> List Application
decodeApplications =
    tolerantDecodeAll applicationDecoder


get : String -> String -> PageIndex -> Int -> Task String (List Value, PageIndex)
get authToken url pageNumber numberPerPage =
    Native.Greenhouse.get authToken url pageNumber numberPerPage

pageRecurse : (PageIndex -> Task String (List a, PageIndex)) -> (List a, PageIndex) -> PageIndex -> Task String (List a, PageIndex)
pageRecurse fn (collection, endNumber) pageNumber =
    if pageNumber < endNumber then
        fn (pageNumber + 1)
            |> Task.map (\(newItems, _) ->
                    (newItems ++ collection, endNumber)
                )
            |> (flip Task.andThen) (\stage -> pageRecurse fn stage (pageNumber + 1))
    else
        Task.succeed (collection, pageNumber)


getUsers : String -> Int -> PageIndex -> Task String (List User)
getUsers authToken numberPerPage pageNumber =
    let
        fn =
            (\pageNumber ->
                get authToken "/v1/candidates" pageNumber numberPerPage
            )
    in
        pageRecurse (fn) ([], pageNumber) 0
            |> Task.map fst
            |> Task.map decodeUsers


getApplication : String -> String -> Task String (List Application)
getApplication authToken applicationId =
    let
        fn =
            (\pageNumber ->
                get authToken ("v1/applications/" ++ applicationId) pageNumber 1
            )
    in
        pageRecurse fn ([], 1) 0
            |> Task.map fst
            |> Task.map decodeApplications

getCandidate : String -> PageIndex -> Int -> String -> Task String Value
getCandidate authToken pageNumber numberPerPage candidateId =
    let
        fn =
            (\pageNumber ->
                get authToken ("v1/candidates/" ++ candidateId) pageNumber numberPerPage
            )
    in
        Debug.crash "not implemented yet"

