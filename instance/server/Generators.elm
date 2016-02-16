module Generators (..) where

import Http.Response.Write exposing (writeHtml, writeJson, writeElm, writeFile, writeNode, writeRedirect)
import Http.Request exposing (emptyReq, Request, Method(..), parseQuery, getQueryField, getFormField, getFormFiles, setForm)
import Http.Response exposing (Response)

import Knox
import Greenhouse exposing (Application, Candidate)
import Moment

import Client.App exposing (successView, genericErrorView)
import Client.Signup.Views exposing (successfulSignupView, alreadySignupView)
import Client.StartTakeHome.Views exposing (beforeTestWelcome, viewTakeHome)
import Client.Admin.Views exposing (allUsersView, successfulRegistrationView, usersSwimlanes)
import Tasks exposing (..)

import Model exposing (Connection, Model, GithubInfo)
import User

import Shared.User exposing (User, initials)
import Shared.Test exposing (testEntryByName)

import Utils exposing (randomUrl)
import Debug
import Maybe
import Result exposing (Result)
import Dict
import Task exposing (Task)
import String


andThen =
    (flip Task.andThen)

onError =
    (flip Task.onError)


tokenAsUrl baseUrl token =
    "http://" ++ baseUrl ++ "?token=" ++ token

{-
Used for generating the response to a take-home submission
Does the following, in order, depentant on each step:

    - Uploads file to S3
    - Creates an issue on Github linking the S3
    - Stores the user details in the database
    - Then generates the successful submission page

-}
generateSuccessPage : Response -> Request -> Model -> Task String ()
generateSuccessPage res req model =
    let
        client =
            Knox.createClient
                { key = model.key
                , secret = model.secret
                , bucket = model.bucket
                }

        newPath user originalFilename =
            String.join
                "/"
                [ user.token
                , originalFilename
                ]

        token =
            getFormField "token" req.form
                |> Maybe.withDefault ""

        handleFiles : User -> Task String User
        handleFiles user =
            case getFormFiles req.form of
                [] ->
                    Task.fail "failed"

                x :: _ ->
                    Knox.putFile x.path (newPath user x.originalFilename) client
                        |> Task.map (\url -> { user | submissionLocation = Just url })
    in
        Tasks.getUser { token = token } model.database
            |> andThen handleFiles
            |> andThen
                (\user ->
                    User.updateUser
                        { token = token }
                        user
                        model.database
                        |> Task.map (\_ -> user)
                )
            |> andThen (\user ->
                let
                    checklist =
                        Dict.get user.role model.checklists
                            |> Maybe.withDefault ""
                in
                    createTakehomeIssue checklist model.github user
                        |> Task.map (\_ -> user)
                )
            |> andThen (\user ->
                case user.submissionLocation of
                    Nothing ->
                        Task.fail "Failed to write url"

                    Just actualUrl ->
                        writeNode (successView user.name actualUrl) res
                )

{-
Used for handling when a user tries to signup and take their take home
Does the following:

    - Takes the email address + application ID from the user
    - if the user already exists, take them to their test page
    - checks this against Greenhouse. If it doesn't match any, fails
    - otherwise, insert the user into the database
-}
generateSignupPage : Response -> Request -> Model -> Task String ()
generateSignupPage res req model =
    let
        applicationId =
            getFormField "applicationId" req.form
                |> Maybe.withDefault "-1"
                |> String.toInt
                |> Result.withDefault -1

        email =
            getFormField "email" req.form
                |> Maybe.withDefault ""
                |> String.trim
                |> String.toLower

        searchUser =
            { applicationId = applicationId
            , email = email
            }

        getToken =
            randomUrl False ""

        test : String -> Maybe Shared.Test.TestEntry
        test jobs =
            testEntryByName jobs model.testConfig
                |> List.head

        jobs : Application -> String
        jobs application =
            List.map (\job -> job.name) application.jobs
                |> String.join ","

        checkValidity : (Candidate, Application) -> Task String (Candidate, Application)
        checkValidity union =
            if isValidGreenhouseCandidate union email applicationId then
                Task.succeed union
            else
                Task.fail "invalid email"

        tryInserting token candidate application =
            let
                role =
                    jobs application

                userWithToken =
                    { name = candidate.firstName ++ " " ++ candidate.lastName
                    , email = email
                    , token = token
                    , applicationId = application.id
                    , role = role
                    , startTime = Nothing
                    , endTime = Nothing
                    , submissionLocation = Nothing
                    , test = test role
                    }

                url =
                    tokenAsUrl model.baseUrl token
            in
                User.insertIntoDatabase userWithToken model.database
                    |> andThen
                        (\_ ->
                            Task.succeed (successfulSignupView url userWithToken)
                        )
    in
        User.getUsers searchUser model.database
            |> andThen
                (\userList ->
                    case userList of
                        [] ->
                            getCandidateByApplication model.authSecret applicationId
                                |> andThen checkValidity
                                |> andThen (\union ->
                                    getToken
                                        |> andThen (\token -> Task.succeed (union, token))
                                    )
                                |> andThen (\((candidate, application), token) ->
                                    tryInserting token candidate application
                                    )
                                |> Task.mapError (\a ->
                                    let
                                        _ = Debug.log "a" a
                                    in
                                        "no such user")

                        existingUser :: [] ->
                            Task.succeed (alreadySignupView (tokenAsUrl model.baseUrl existingUser.token) existingUser)

                        _ ->
                            Task.fail "multiple users found with that name and email address"
                )
            |> andThen (\node -> writeNode node res)


generateWelcomePage : String -> Response -> Model -> Task String ()
generateWelcomePage token res model =
    Tasks.getUser { token = token } model.database
        |> andThen
            (\user ->
                case testEntryByName user.role model.testConfig of
                    [] ->
                        Task.fail ("No matching roles! Please message " ++ model.contact)

                    testEntry :: _ ->
                        writeNode (beforeTestWelcome user testEntry) res
            )



generateTestPage : Response -> Request -> Model -> Task String ()
generateTestPage res req model =
    let
        token =
            getFormField "token" req.form
                |> Maybe.withDefault ""

        startTime =
            Moment.getCurrent ()

        app obj =
            writeElm "/Client/StartTakeHome/App" (Just obj) res
    in
        Tasks.getUser { token = token } model.database
            |> andThen
                (\user ->
                    case testEntryByName user.role model.testConfig of
                        [] ->
                            Task.fail "No matching roles!"

                        testEntry :: _ ->
                            case user.startTime of
                                Nothing ->
                                    let
                                        updatedUser =
                                            { user
                                                | startTime = Just startTime
                                            }

                                        obj =
                                            { name = "TelateProps"
                                            , val =
                                                { user = updatedUser
                                                , test = testEntry
                                                }
                                            }
                                    in
                                        User.updateUser { token = token } updatedUser model.database
                                            |> andThen (\_ -> app obj)

                                Just time ->
                                    app
                                        { name = "TelateProps"
                                        , val =
                                            { user = user
                                            , test = testEntry
                                            }
                                        }
                )


generateAdminPage : Response -> Request -> Model -> Task String ()
generateAdminPage res req model =
    let
        password =
            getFormField "password" req.form
                |> Maybe.withDefault ""

        attemptLogin =
            if password == model.authSecret then
                Task.succeed ()
            else
                Task.fail "Invalid password"
    in
        attemptLogin
            |> andThen (\_ -> User.getUsers {} model.database)
            |> andThen (\users -> writeNode (allUsersView users) res)


generateSwimPage : Response -> Request -> Model -> Task String ()
generateSwimPage res req model =
    getTeamMembers "frontend" model.github
        |> andThen (\_ -> User.getUsers {} model.database)
        |> andThen (\users -> writeNode (usersSwimlanes users) res)

