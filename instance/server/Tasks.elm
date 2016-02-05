module Tasks where

import String
import Task exposing (Task)

--import Greenhouse
import Github

import Shared.User exposing (User, initials)
import Model exposing (GithubInfo)

--getUsersFromGreenhouse : Task String (List Greenhouse.User)
--getUsersFromGreenhouse =
--    Greenhouse.getUsers "" 1 100


createTakehomeIssue : GithubInfo -> User -> Task String ()
createTakehomeIssue info user =
    let
        text =
            case user.submissionLocation of
                Nothing ->
                    "Something went wrong with the submission for the user " ++ (toString user)
                Just url ->
                    String.join "" [ "Please review the take home found [here]("
                    , url
                    , ")"
                    , "\n\n"
                    ]

        settings =
            { user = info.org
            , repo = info.repo
            , title = "Review take home for " ++ (initials user)
            , body = Just text
            , assignee = Just info.assignee
            , milestone = Nothing
            , labels = []
            }
    in
        Github.createSession Github.defaultSession
            |> Debug.log "session"
            |> Github.authenticate info.auth
            |> Github.createIssue settings

getTeams : GithubInfo -> Task String (List String)
getTeams info =
    Github.createSession Github.defaultSession
        |> Github.authenticate info.auth
        |> Github.getTeams info.org Nothing Nothing
