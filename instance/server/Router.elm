module Router where

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

import Model exposing (Connection, Model)
import Client.App exposing (index, genericErrorView)
import Client.Signup.Views exposing (signUpForTakeHomeView)
import Generators exposing (generateSuccessPage
  , generateSignupPage, generateWelcomePage
  , generateTestPage
  )

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

type Action
  = Incoming Connection
  | Run ()
  | Noop

type StartAppAction
  = Init Model
  | Update Action

{-| when we don't want to 500, write an error view
-}
handleError : Response -> Task a () -> Task b ()
handleError res errTask =
  errTask
    |> (flip Task.onError) (\_ -> writeNode genericErrorView res)

runRoute task =
  task
    |> Task.map Run
    |> Effects.task

hasQuery url =
  String.contains "?" url

queryPart url =
  String.indexes "?" url
    |> (\xs ->
      case xs of
        [] -> ""
        x::_ -> String.dropLeft (x + 1) url
      )

{-| route each request/response pair and write a response
-}
routeIncoming : Connection -> Model -> (Model, Effects Action)
routeIncoming (req, res) model =
  let
    runRouteWithErrorHandler =
      (handleError res) >> runRoute
  in
    case req.method of
      GET ->
        case req.url of
          "/" ->
            model =>
              (writeNode (signUpForTakeHomeView model.testConfig) res
                |> runRouteWithErrorHandler)
          url ->
            case hasQuery url of
              False ->
                model =>
                  (writeFile url res
                      |> runRouteWithErrorHandler)
              True ->
                case parseQuery <| queryPart url of
                  Err _ ->
                    model =>
                      (Task.fail "failed to parse"
                        |> runRouteWithErrorHandler)
                  Ok bag ->
                    case getQueryField "token" bag of
                      Nothing ->
                        model =>
                          (writeFile ("<h1>failed to find anything</h1>" ++ url) res
                            |> runRoute)

                      Just token ->
                        model =>
                          (generateWelcomePage token res model
                            |> runRouteWithErrorHandler)

      POST ->
        case req.url of
          "/apply" ->
            model =>
              (setForm req
                |> (flip andThen) (\req -> generateSuccessPage res req model)
                |> runRouteWithErrorHandler)

          "/signup" ->
            model =>
              (setForm req
                |> (flip andThen) (\req -> generateSignupPage res req model)
                |> runRouteWithErrorHandler)
          "/start-test" ->
            model =>
              (setForm req
                |> (flip andThen) (\req -> generateTestPage res req model)
                |> runRouteWithErrorHandler)
          _ ->
            model => Effects.none

      NOOP ->
        model => Effects.none

      _ ->
        model =>
          (writeJson (Json.string "unknown method!") res
            |> runRoute)


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Incoming connection -> routeIncoming connection model
    Run _ -> (model, Effects.none)
    Noop -> (model, Effects.none)

uniqueUrl : String -> Maybe String
uniqueUrl url =
  let
    uniqueRegex =
      Regex.regex "?token=(.+)(&.)"
  in
    case Regex.find (Regex.AtMost 1) uniqueRegex url of
      [] -> Nothing
      uniqueMatch::_ ->
        case uniqueMatch.submatches of
          uniqueString::_::[] -> uniqueString
          _ -> Nothing

(=>) = (,)
