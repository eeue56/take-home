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

import Client.App exposing (index, successView)

import Task exposing (..)
import Signal exposing (..)
import Json.Encode as Json
import Maybe
import Result
import Effects exposing (Effects)

import Debug

type Action
  = Incoming Connection
  | Run ()
  | Noop


generateSuccessPage : Response -> Request -> Task a ()
generateSuccessPage res req =
  let
    view =
      getFormField "name" req.form
        |> Maybe.withDefault "anon"
        |> successView
    in
      writeNode view res

routeIncoming : Connection -> Model -> (Model, Effects Action)
routeIncoming (req, res) model =
  case req.method of
    GET ->
      case req.url of
        "/" ->
          model =>
            (writeNode index res
              |> Task.map Run
              |> Effects.task)
        url ->
          model =>
            (writeFile url res
              |> Task.map Run
              |> Effects.task)

    POST ->
      case req.url of
        "/apply" ->
          model =>
            (setForm req
              |> (flip andThen) (generateSuccessPage res)
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
