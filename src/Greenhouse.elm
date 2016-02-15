module Greenhouse where

import Task exposing (Task)
import Json.Decode as Json exposing (..)
import Json.Decode.Extra exposing (apply, (|:))
import Native.Greenhouse


type alias PageIndex = Int

type alias Candidate =
    { id : Int
    , firstName : String
    , lastName : String
    , applicationIds : List Int
    , emailAddresses : List EmailAddress
    }

type alias Job =
    { id : Int
    , name : String
    }

type alias EmailAddress =
    { type' : String
    , value : String
    }

type alias Application =
    { id : Int
    , candidateId : Int
    , prospect : Bool
    , status : String
    , jobs : List Job
    }

candidateDecoder : Decoder Candidate
candidateDecoder =
    succeed Candidate
        |: ("token" := int)
        |: ("name" := string)
        |: ("email" := string)
        |: ("role" := list int)
        |: ("emailAddresses" := list emailDecoder)

jobDecoder : Decoder Job
jobDecoder =
    succeed Job
        |: ("id" := int)
        |: ("name" := string)

emailDecoder : Decoder EmailAddress
emailDecoder =
    succeed EmailAddress
        |: ("type" := string)
        |: ("value" := string)

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
decodeCandidates : List Json.Value -> List Candidate
decodeCandidates =
    tolerantDecodeAll candidateDecoder

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


getCandidates : String -> Int -> PageIndex -> Task String (List Candidate)
getCandidates authToken numberPerPage pageNumber =
    let
        fn =
            (\pageNumber ->
                get authToken "/v1/candidates" pageNumber numberPerPage
            )
    in
        pageRecurse (fn) ([], pageNumber) 0
            |> Task.map fst
            |> Task.map decodeCandidates


getApplication : String -> Int -> Task String (List Application)
getApplication authToken applicationId =
    let

        fn =
            (\pageNumber ->
                get authToken ("v1/applications/" ++ (toString applicationId)) pageNumber 1
            )
    in
        pageRecurse fn ([], 1) 0
            |> Task.map fst
            |> Task.map decodeApplications

getCandidate : String -> Int -> Task String (List Candidate)
getCandidate authToken candidateId =
    let
        fn =
            (\pageNumber ->
                get authToken ("v1/candidates/" ++ (toString candidateId)) pageNumber 1
            )
    in
        pageRecurse fn ([], 1) 0
            |> Task.map fst
            |> Task.map decodeCandidates

candidateHasEmail : Candidate -> String -> Bool
candidateHasEmail candidate email =
    List.any (\singleEmail -> singleEmail.value == email) candidate.emailAddresses
