module Tasks where

import String
import Task exposing (Task)
import Dict exposing (Dict)

--import Greenhouse
import Github
import Database.Nedb exposing (Client)

import Shared.User exposing (User, initials)
import Model exposing (GithubInfo)
import User

andThen =
    (flip Task.andThen)


{-|
Creates the issue on github, using the checklist, the github info, and the user
-}
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

{-|
Gets teams from github for a certain organiation
-}
getTeams : GithubInfo -> Task String (Dict String Github.Team)
getTeams info =
    Github.createSession Github.defaultSession
        |> Github.authenticate info.auth
        |> Github.getTeams info.org Nothing Nothing

{-|
Get the team members from a given team
-}
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

{-|
Finds a single user in the database
-}
getUser : a -> Client -> Task String User
getUser query database =
    User.getUsers query database
        |> andThen
            (\userList ->
                case userList of
                    [] -> Task.fail "No such user"
                    [x] -> Task.succeed x
                    _ -> Task.fail "Too many matches"
            )

