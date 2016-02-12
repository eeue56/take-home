module Router (..) where

import Http.Response.Write exposing (writeHtml, writeJson, writeCss, writeElm, writeFile, writeNode, writeRedirect)
import Http.Request exposing (emptyReq, Request, Method(..), parseQuery, getQueryField, getFormField, getFormFiles, setForm)
import Http.Response exposing (Response)
import Model exposing (Connection, Model, Session)
import Client.App exposing (index, genericErrorView)
import Client.Signup.Views exposing (signUpForTakeHomeView)
import Generators exposing (generateSuccessPage, generateSignupPage,
    generateWelcomePage, generateTestPage, generateAdminPage,
    generateSuccessfulRegistrationPage, generateSwimPage)
import Client.Admin.Views exposing (loginView, registerUserView)
import Shared.Routes exposing (Route(..), routes, assets)
import Task exposing (..)
import Signal exposing (..)
import Json.Encode as Json
import Maybe
import Result exposing (Result)
import Effects exposing (Effects)
import Dict
import Regex
import String
import Env
import Converters
import Debug
import RouteParser exposing (match)


type Action
    = Incoming Connection
    | Run ()
    | AddSession Session
    | Noop


type StartAppAction
    = Init Model
    | Update Action


{-| when we don't want to 500, write an error view
-}
handleError : Response -> Task a () -> Task b ()
handleError res errTask =
    errTask
        |> (flip Task.onError) (\err -> writeNode (genericErrorView err) res)


{-| Actually queue the response up
-}
runRoute task =
    task
        |> Task.map (\_ -> AddSession { token = "hello" } )
        |> Effects.task


{-| Get any part of a string past `?`.
Useful for getting a query string out of a url
-}
queryPart : String -> String
queryPart url =
    String.indexes "?" url
        |> (\xs ->
                case xs of
                    [] ->
                        ""

                    x :: _ ->
                        String.dropLeft (x + 1) url
           )


{-| Route any `POST` requests
-}
routePost : Connection -> Model -> ( Model, Effects Action )
routePost ( req, res ) model =
    let
        runRouteWithErrorHandler =
            (handleError res) >> runRoute

        possibleRoute =
            match routes req.url

        generate generator =
            (setForm req
                |> (flip andThen) (\req -> generator res req model)
                |> runRouteWithErrorHandler
            )
    in
        case possibleRoute of
            Just route ->
                case route of
                    Apply ->
                        model
                            => generate generateSuccessPage
                    SignUp ->
                        model
                            => generate generateSignupPage
                    StartTest ->
                        model
                            => generate generateTestPage
                    Login ->
                        model
                            => generate generateAdminPage
                    RegisterUser ->
                        model
                            => generate generateSuccessfulRegistrationPage
            Nothing ->
                model
                    => (handleError res (Task.fail "Route not found")
                            |> runRouteWithErrorHandler
                       )

{-| Route any `GET` requests
-}
routeGet : Connection -> Model -> ( Model, Effects Action )
routeGet ( req, res ) model =
    let
        runRouteWithErrorHandler =
            (handleError res) >> runRoute

        possibleRoute =
            match routes req.url
    in
        case possibleRoute of
            Just route ->
                Index ->
                    model
                        => (writeNode (signUpForTakeHomeView model.testConfig) res
                                |> runRouteWithErrorHandler

                Login ->
                    model
                        => (writeNode loginView res
                                |> runRouteWithErrorHandler
                           )
                RegisterUser ->
                    model
                        => (writeNode registerUserView res
                                |> runRouteWithErrorHandler
                           )
            Nothing ->
                else if url == assets.admin.route then
                    model
                        => (writeCss assets.admin.css res
                                |> runRouteWithErrorHandler
                           )
                else if url == assets.main.route then
                    model
                        => (writeCss assets.main.css res
                                |> runRouteWithErrorHandler
                           )
                else if url == routes.swimlanes then
                    model
                        => (generateSwimPage res req model
                                |> runRouteWithErrorHandler
                            )
                else if url == assets.signup.route then
                    model
                        => (writeCss assets.signup.css res
                                |> runRouteWithErrorHandler
                           )
                else if url == assets.start.route then
                    model
                        => (writeCss assets.start.css res
                                |> runRouteWithErrorHandler
                            )
                else if url == assets.noredinkLogo.route then
                    let
                        _ =
                            Debug.log "noredink logo requestd " assets.noredinkLogo
                    in
                        model
                            => (writeFile assets.noredinkLogo.file res
                                    |> runRouteWithErrorHandler
                                )
                else
                    case queryPart url of
                        "" ->
                            model
                                => (writeFile url res
                                        |> runRouteWithErrorHandler
                                   )

                        query ->
                            case parseQuery query of
                                Err _ ->
                                    model
                                        => (Task.fail "failed to parse"
                                                |> runRouteWithErrorHandler
                                           )

                                Ok bag ->
                                    case getQueryField "token" bag of
                                        Nothing ->
                                            model
                                                => (Task.fail ("Failed to find anything " ++ url)
                                                        |> runRouteWithErrorHandler
                                                   )

                                        Just token ->
                                            model
                                                => (generateWelcomePage token res model
                                                        |> runRouteWithErrorHandler
                                                   )


{-| route each request/response pair and write a response
-}
routeIncoming : Connection -> Model -> ( Model, Effects Action )
routeIncoming ( req, res ) model =
    case req.method of
        GET ->
            routeGet ( req, res ) model

        POST ->
            routePost ( req, res ) model

        NOOP ->
            model => Effects.none

        _ ->
            model
                => (writeJson (Json.string "unknown method!") res
                        |> runRoute
                   )


update : Action -> Model -> ( Model, Effects Action )
update action model =
    case action of
        Incoming connection ->
            routeIncoming connection model

        Run _ ->
            ( model, Effects.none )

        AddSession token ->
            ( model, Effects.none )

        Noop ->
            ( model, Effects.none )


(=>) =
    (,)
