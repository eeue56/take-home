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

import Client.App exposing (successView, genericErrorView)
import Client.Signup.Views exposing (successfulSignupView, alreadySignupView)
import Client.StartTakeHome.Views exposing (beforeTestWelcome, viewTakeHome)

import Model exposing (Connection, Model)
import User
import Shared.User exposing (User)
import Shared.Test exposing (testEntryByName)

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


--uploadFile : String -> String -> Knox.Client -> Task (Result String String) String
uploadFile fileName fileNameOnServer client =
    Knox.putFile fileName fileNameOnServer client


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

        view =
            successView name

        handleFiles =
            case getFormFiles req.form of
                [] ->
                    Debug.log "no files" <| Task.succeed "failed"
                x::_ ->
                  uploadFile x.path (newPath x.originalFilename) client

    in
        handleFiles
            |> andThen (\url -> writeNode (view url) res)


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
            model.baseUrl ++ "?token=" ++ token

        tryInserting token =
            let
                userWithToken =
                    { name = name
                    , email = email
                    , token = token
                    , role = role
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
                    writeRedirect "/" res
                existingUser :: [] ->
                    case testEntryByName existingUser.role model.testConfig of
                        [] ->
                            Task.fail "No matching roles!"
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
    in
        User.getUsers { token = token } model.database
            |> andThen (\userList ->
                case userList of
                    [] ->
                        writeRedirect "/" res
                    existingUser :: [] ->
                        case testEntryByName existingUser.role model.testConfig of
                            [] ->
                                Task.fail "No matching roles!"
                            testEntry :: _ ->
                                writeNode (viewTakeHome testEntry) res
                    _ ->
                        Debug.crash "This should be impossible"
                )
