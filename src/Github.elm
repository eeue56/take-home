module Github where

import Json.Decode as Decode exposing ((:=), Decoder, succeed)
import Json.Encode as Json exposing (string, object)
import Json.Encode.Extra exposing (maybe, objectFromList)
import Json.Decode.Extra exposing (apply, (|:))

import Task exposing (Task)
import Dict exposing (Dict)

import Native.Github

type Protocol = Https | Http

type Session = Session

type alias SessionConfig =
    { version : String
    , debug : Bool
    , protocol : String -- TODO: use Protocol type instead
    , host : String
    , pathPrefix : String
    , timeout : Int
    }

defaultSession : SessionConfig
defaultSession =
    { version = "3.0.0"
    , debug = True
    , protocol = "https"
    , host = "api.github.com"
    , pathPrefix = ""
    , timeout = 3000
    }

type alias IssueCreationSettings =
    { user : String
    , repo : String
    , title : String
    , body : Maybe String
    , assignee : Maybe String
    , milestone : Maybe Int
    , labels : List String
    }

type alias Team =
    { name : String
    , id : Int
    , slug : String
    }

type alias Member =
    { login: String
    }

memberDecoder : Decoder Member
memberDecoder =
    succeed Member
        |: ("login" := Decode.string)

type Auth
    = KeySecret String String
    | Token String
    | Basic String String

encodeIssueCreationSettings : IssueCreationSettings -> Json.Value
encodeIssueCreationSettings settings =
    let
        gatheredSettings : List (String, Json.Value)
        gatheredSettings =
            [ ( "user", string settings.user)
            , ( "repo", string settings.repo)
            , ( "title", string settings.title)
            , ( "labels",
                List.map string settings.labels
                    |> Json.list
              )
            ]
    in
        [ gatheredSettings
        , maybe string "assignee" settings.assignee
        , maybe string "body" settings.body
        , maybe Json.int "milestone" settings.milestone
        ]
            |> objectFromList


encodeAuth : Auth -> Json.Value
encodeAuth auth =
    let
        createField name value =
            (name, Json.string value)
        oauthType =
            createField "type" "oauth"

        fields =
            case auth of
                KeySecret key secret ->
                    [ oauthType
                    , createField "key" key
                    , createField "secret" secret
                    ]
                Token token ->
                    [ oauthType
                    , createField "token" token
                    ]
                Basic username password ->
                    [ createField "type" "basic"
                    , createField "username" username
                    , createField "password" password
                    ]
    in
        Json.object fields


createSession : SessionConfig -> Session
createSession =
    Native.Github.createSession

authenticate : Auth -> Session -> Session
authenticate auth session =
    Native.Github.authenticate (encodeAuth auth) session

createIssue : IssueCreationSettings -> Session -> Task String String
createIssue settings session =
    Native.Github.createIssue (encodeIssueCreationSettings settings) session
        |> (flip Task.andThen)
            (Decode.decodeValue ("html_url" := Decode.string) >> Task.fromResult)

getTeams : String -> Maybe Int -> Maybe Int -> Session -> Task String (Dict String Team)
getTeams org pageNumber perPage session =
    let
        encodedObject =
            [ [ ( "org", string org ) ]
            , maybe Json.int "page" pageNumber
            , maybe Json.int "per_page" perPage
            ]
                |> objectFromList

        nativeGetTeams : Json.Value -> Session -> Task String (List Team)
        nativeGetTeams =
            Native.Github.getTeams
    in
        nativeGetTeams encodedObject session
            |> Task.map (List.map (\team -> (team.name, team)))
            |> Task.map (Dict.fromList)


getTeamMembers : Int -> Session -> Task String (List String)
getTeamMembers teamId session =
    let
        encodedObject =
            [ [ ("id", Json.int teamId) ] ]
                |> objectFromList
    in
        Native.Github.getTeamMembers encodedObject session
            |> Task.map (List.map (\x -> x.login))
