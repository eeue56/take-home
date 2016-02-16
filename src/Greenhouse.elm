module Greenhouse where

import Task exposing (Task)
import Json.Decode as Json exposing (..)
import Json.Encode as Encode
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

type alias NotePost =
    { userId : Int
    , body : String
    , visibility : String
    }

nodePostEncoder : NotePost -> String
nodePostEncoder post =
    (Encode.encode 0 << Encode.object)
        [ ("user_id", Encode.int post.userId )
        , ("body", Encode.string post.body)
        , ("visibility", Encode.string post.visibility)
        ]

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
        |: ("id" := int)
        |: ("first_name" := string)
        |: ("last_name" := string)
        |: ("application_ids" := list int)
        |: ("email_addresses" := list emailDecoder)

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
        |: ("candidate_id" := int)
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


getMany : String -> String -> PageIndex -> Int -> Task String (List Value, PageIndex)
getMany authToken url pageNumber numberPerPage =
    Native.Greenhouse.getMany authToken url pageNumber numberPerPage

getOne : String -> String -> Task String Value
getOne =
    Native.Greenhouse.getOne

postOne : String -> Int -> String -> String -> Task String Value
postOne authToken userId args url =
    Native.Greenhouse.postOne authToken userId args url

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
                getMany authToken "/v1/candidates" pageNumber numberPerPage
            )
    in
        pageRecurse (fn) ([], pageNumber) 0
            |> Task.map fst
            |> Task.map decodeCandidates

--/" ++ (toString applicationId)

getApplication : String -> Int -> Task String (Maybe Application)
getApplication authToken applicationId =
    getOne authToken ("/v1/applications/" ++ (toString applicationId))
        |> Task.map (Json.decodeValue applicationDecoder >> Result.toMaybe)

getCandidate : String -> Int -> Task String (Maybe Candidate)
getCandidate authToken candidateId =
    getOne authToken ("/v1/candidates/" ++ (toString candidateId))
        |> Task.map (Json.decodeValue candidateDecoder >> Result.toMaybe)

addNote : String -> Int -> NotePost -> Int -> Task String (Value)
addNote authToken userId note candidateId =
    let
        url =
            ("https://harvest.greenhouse.io/v1/candidates/" ++ (toString candidateId) ++ "/activity_feed/notes")
        body =
            nodePostEncoder note
    in
        postOne authToken userId body url

candidateHasEmail : Candidate -> String -> Bool
candidateHasEmail candidate email =
    List.any (\singleEmail -> singleEmail.value == email) candidate.emailAddresses
