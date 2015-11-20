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

handleError : Response -> Task a () -> Task a ()
handleError res errTask =
  errTask
    |> (flip Task.onError) (\_ -> writeNode genericErrorView res)


routeIncoming : Connection -> Model -> (Model, Effects Action)
routeIncoming (req, res) model =
  let
    actuallyHandleError : Task a () -> Task a ()
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
            model =>
              (writeFile url res
                |> actuallyHandleError
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


(=>) = (,)
