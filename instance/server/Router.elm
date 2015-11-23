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
import Client.App exposing (index, signUpForTakeHomeView, genericErrorView)
import Generators exposing (generateSuccessPage, generateSignupPage)

import Task exposing (..)
import Signal exposing (..)
import Json.Encode as Json
import Maybe
import Result exposing (Result)
import Effects exposing (Effects)
import Dict
import Regex

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

{-| route each request/response pair and write a response
-}
routeIncoming : Connection -> Model -> (Model, Effects Action)
routeIncoming (req, res) model =
  let
    actuallyHandleError : Task a () -> Task b ()
    actuallyHandleError =
      handleError res
  in
    case req.method of
      GET ->
        case req.url of
          "/" ->
            model =>
              (writeNode signUpForTakeHomeView res
                |> actuallyHandleError
                |> Task.map Run
                |> Effects.task)
          url ->
            case parseQuery url of
              Err _ ->
                model =>
                  (writeFile url res
                    |> actuallyHandleError
                    |> Task.map Run
                    |> Effects.task)
              Ok bag ->
                case getQueryField "/token" bag of
                  Nothing ->
                    let
                      _ = Debug.log "erm" bag
                    in
                      model =>
                        (writeHtml ("<h1>failed to find anything</h1>" ++ url) res
                          |> Task.map Run
                          |> Effects.task)

                  Just token ->
                    let
                      _ =
                        Debug.log "hello" token


                    in
                      model =>
                        (writeHtml token res
                          |> Task.map Run
                          |> Effects.task)

      POST ->
        case req.url of
          "/apply" ->
            model =>
              (setForm req
                |> (flip andThen) (\req -> generateSuccessPage res req model)
                |> actuallyHandleError
                |> Task.map Run
                |> Effects.task)

          "/signup" ->
            model =>
              (setForm req
                |> (flip andThen) (\req -> generateSignupPage res req model)
                |> actuallyHandleError
                |> Task.map Run
                |> Effects.task)

          _ ->
            model => Effects.none

      NOOP ->
        model => Effects.none

      _ ->
        model =>
          (writeJson (Json.string "unknown method!") res
            |> Task.map Run
            |> Effects.task)


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
