module Github where

import Json.Encode as Json exposing (string, object)
import Task exposing (Task)

import Native.Github

type Protocol = Https | Http

type alias GithubSession =
    { version : String
    , debug : Bool
    , protocol : String -- TODO: use Protocol type instead
    , host : String
    , pathPrefix : String
    , timeout : Int
    }

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

type GithubAuth
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

        assigneeItem assignee =
            ( "assignee", string assignee)

        bodyItem body =
            ( "body", string body)


        maybeStringItems =
            case (settings.body, settings.assignee) of
                (Nothing, Nothing) ->
                    []
                (Just body, Nothing) ->
                    [ bodyItem body ]
                (Nothing, Just assignee) ->
                    [ assigneeItem assignee ]
                (Just body, Just assignee ) ->
                    [ assigneeItem assignee
                    , bodyItem body
                    ]

        maybeMilestone =
            case settings.milestone of
                Nothing ->
                    []
                Just milestone ->
                    [ ("milestone", Json.int milestone) ]
    in
        [ gatheredSettings
        , maybeStringItems
        , maybeMilestone
        ]
            |> List.concat
            |> Json.object


encodeGithubAuth : GithubAuth -> Json.Value
encodeGithubAuth auth =
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


createIssue : GithubSession -> GithubAuth -> IssueCreationSettings -> Task String ()
createIssue session auth settings =
    Native.Github.createIssue
        session
        (encodeGithubAuth auth)
        (encodeIssueCreationSettings settings)
