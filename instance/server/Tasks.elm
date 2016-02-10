module Tasks where

import String
import Task exposing (Task)
import Dict exposing (Dict)

--import Greenhouse
import Github

import Shared.User exposing (User, initials)
import Model exposing (GithubInfo)

andThen =
    (flip Task.andThen)

--getUsersFromGreenhouse : Task String (List Greenhouse.User)
--getUsersFromGreenhouse =
--    Greenhouse.getUsers "" 1 100



createTakehomeIssue : String -> GithubInfo -> User -> Task String ()
createTakehomeIssue checkList info user =
    let
        text =
            case user.submissionLocation of
                Nothing ->
                    "Something went wrong with the submission for the user "
                Just url ->
                    String.join "" [ "Please review the take home found [here]("
                    , url
                    , ")"
                    , "\n\n"
                    , checkList
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
            |> Github.authenticate info.auth
            |> Github.createIssue settings

getTeams : GithubInfo -> Task String (Dict String Github.Team)
getTeams info =
    Github.createSession Github.defaultSession
        |> Github.authenticate info.auth
        |> Github.getTeams info.org Nothing Nothing

getTeamMembers : String -> GithubInfo -> Task String (List String)
getTeamMembers teamName info =
    getTeams info
        |> andThen
            (\teams ->
                case Dict.get teamName teams of
                    Nothing ->
                        Task.fail "no such team"
                    Just team ->
                        Task.succeed team.id
            )
        |> andThen (\id ->
            Github.createSession Github.defaultSession
                |> Github.authenticate info.auth
                |> Github.getTeamMembers id
        )
