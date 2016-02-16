module Tasks where

import String
import Task exposing (Task)
import Dict exposing (Dict)

import Greenhouse exposing (Candidate, Application)
import Github
import Database.Nedb exposing (Client)

import Shared.User exposing (User, initials)
import Model exposing (GithubInfo)
import User

import Array
import Random.Impure exposing (withinRange)


andThen =
    (flip Task.andThen)


{-|
Creates the issue on github, using the checklist, the github info, and the user
-}
createTakehomeIssue : String -> String -> GithubInfo -> User -> Task String String
createTakehomeIssue checkList assignee info user =
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
            , assignee = Just assignee
            , milestone = Nothing
            , labels = []
            }
    in
        Github.createSession Github.defaultSession
            |> Github.authenticate info.auth
            |> Github.createIssue settings

createTakehomeNote : String -> Int -> Int -> String -> Task String ()
createTakehomeNote authToken userId candidateId githubUrl =
    let
        note =
            { userId = userId
            , body = "Github issue for takehome: " ++ githubUrl
            , visibility = "public"
            }
    in
        Greenhouse.addNote authToken userId note candidateId
            |> Task.map (\_ -> ())

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

chooseTeamMember : List String -> Task String (Maybe String)
chooseTeamMember teamMembers =
    Array.fromList teamMembers
        |> (\team ->
            let
                max =
                    Array.length team
                min =
                    0
            in
                withinRange min max
                    |> andThen (\index -> Task.succeed <| Array.get index team)
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


getCandidateByApplication : String -> Int -> Task String (Candidate, Application)
getCandidateByApplication authToken applicationId =
    Greenhouse.getApplication authToken applicationId
        |> andThen (\maybeApplication ->
            case maybeApplication of
                Just application ->
                    Task.succeed application
                Nothing ->

                    Task.fail <| Debug.log "here" "Invalid id"
            )
        |> andThen (\application ->
            Greenhouse.getCandidate authToken application.candidateId
                |> andThen (\maybeCandidate ->
                    case maybeCandidate of
                        Just candidate ->
                            Task.succeed ( candidate, application )
                        Nothing ->
                            Task.fail "Invalid email"
                    )
            )

isValidGreenhouseCandidate : (Candidate, Application) -> String -> Int -> Bool
isValidGreenhouseCandidate (candidate, application) email applicationId =
    application.id == applicationId &&
        Greenhouse.candidateHasEmail candidate email
