module Generators where

import Http.Response.Write exposing (writeHtml
    , writeJson
    , writeElm, writeFile
    , writeNode, writeRedirect)

import Http.Request exposing (emptyReq
    , Request, Method(..)
    , parseQuery, getQueryField
    , getFormField, getFormFiles
    , setForm
    )

import Http.Response exposing (Response)
import Http.Server

import Knox
import Database.Nedb as Database
import Moment

import Client.App exposing (successView, genericErrorView)
import Client.Signup.Views exposing (successfulSignupView, alreadySignupView)
import Client.StartTakeHome.Views exposing (beforeTestWelcome, viewTakeHome)
import Client.Admin.Views exposing (allUsersView)

import Model exposing (Connection, Model)
import User
import Shared.User exposing (User)
import Shared.Test exposing (testEntryByName)

import Shared.Routes exposing (routes)

import Utils exposing (randomUrl)

import Debug
import Maybe
import Result exposing (Result)
import Effects exposing (Effects, Never(..))
import Dict
import Task exposing (Task)
import String

andThen = (flip Task.andThen)
onError = (flip Task.onError)


--generateSuccessPage : Response -> Request -> Model -> Task b ()
generateSuccessPage res req model =
    let
        client =
            Knox.createClient
                { key = model.key
                , secret = model.secret
                , bucket = model.bucket
                }

        newPath originalFilename =
            String.join "/"
                [ name
                , email
                , originalFilename
                ]

        name =
            getFormField "name" req.form
                |> Maybe.withDefault "anon"

        email =
            getFormField "email" req.form
                |> Maybe.withDefault "anon"

        handleFiles =
            case getFormFiles req.form of
                [] ->
                    Debug.log "no files" <| Task.fail "failed"
                x::_ ->
                  Knox.putFile x.path (newPath x.originalFilename) client

    in
        handleFiles
            |> andThen (\url -> writeNode (successView name url) res)


generateSignupPage : Response -> Request -> Model -> Task String ()
generateSignupPage res req model =
    let
        name =
            getFormField "name" req.form
                |> Maybe.withDefault "anon"
        email =
            getFormField "email" req.form
                |> Maybe.withDefault "anon"
        role =
            getFormField "role" req.form
                |> Maybe.withDefault "none"

        searchUser =
            { name = name
            , email = email
            }

        getToken =
            randomUrl False ""

        tokenAsUrl token =
            "http://" ++ model.baseUrl ++ "?token=" ++ token

        tryInserting token =
            let
                userWithToken =
                    { name = name
                    , email = email
                    , token = token
                    , role = role
                    , startTime = Nothing
                    , endTime = Nothing
                    , submissionLocation = Nothing
                    }

                url =
                    tokenAsUrl token
            in
                User.insertIntoDatabase userWithToken model.database
                    |> andThen (\_ ->
                        Task.succeed (successfulSignupView url userWithToken)
                        )

    in
        User.getUsers { name = name, email = email } model.database
            |> andThen (\userList ->
                case userList of
                    [] ->
                        getToken
                            |> andThen tryInserting
                            |> Task.mapError (\_ -> "no such user")

                    existingUser :: [] ->
                        Task.succeed (alreadySignupView (tokenAsUrl existingUser.token) existingUser)

                    _ ->
                        Task.fail "multiple users found with that name and email address"
                )
            |> andThen (\node -> writeNode node res)


generateWelcomePage : String -> Response -> Model -> Task String ()
generateWelcomePage token res model =
    User.getUsers { token = token } model.database
        |> andThen (\userList ->
            case userList of
                [] ->
                    writeRedirect routes.index res
                existingUser :: [] ->
                    case testEntryByName existingUser.role model.testConfig of
                        [] ->
                            Task.fail ("No matching roles! Please message " ++ model.contact)
                        testEntry :: _ ->
                            writeNode (beforeTestWelcome existingUser testEntry) res
                _ ->
                    Debug.crash "This should be impossible!"
            )

generateTestPage : Response -> Request -> Model -> Task String ()
generateTestPage res req model =
    let
        token =
            getFormField "token" req.form
                |> Maybe.withDefault ""

        startTime  =
            Moment.getCurrent ()

        app obj =
            writeElm "/Client/StartTakeHome/App" (Just obj) res
    in
        User.getUsers { token = token } model.database
            |> andThen (\userList ->
                case userList of
                    [] ->
                        writeRedirect routes.index res
                    existingUser :: [] ->
                        case testEntryByName existingUser.role model.testConfig of
                            [] ->
                                Task.fail "No matching roles!"
                            testEntry :: _ ->
                                case existingUser.startTime of
                                    Nothing ->
                                        let
                                            updatedUser =
                                                { existingUser
                                                | startTime = Just startTime }

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
                                            , val = { user = existingUser
                                                    , test = testEntry}
                                            }

                    _ ->
                        Debug.crash "This should be impossible"
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
