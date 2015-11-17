module Main where

import Http.Server exposing (..)
import Http.Request exposing (emptyReq
  , Request, Method(..)
  , parseQuery, getQueryField
  , getFormField, getFormFiles
  , setForm
  )
import Http.Response exposing (emptyRes, Response)
import Http.Response.Write exposing
  ( writeHtml, writeJson
  , writeElm, writeFile
  , writeNode, writeRedirect)

import Env exposing (getEnv)

import Client.App exposing (index, successView)

import Task exposing (..)
import Signal exposing (..)
import Json.Encode as Json
import Maybe
import Result
import Debug exposing (log)

import Effects exposing (Effects)
import StartApp exposing (start)


type alias Model =
  { auth : String
  , secret : String
  }

type alias Connection =
  (Request, Response)

type Action
  = Incoming Connection
  | Run ()
  | Noop

server : Mailbox Connection
server = mailbox (emptyReq, emptyRes)

generateSuccessPage : Response -> Request -> Task a ()
generateSuccessPage res req =
  let
    view =
      getFormField "name" req.form
        |> Maybe.withDefault "anon"
        |> successView
    in
      writeNode view res


model =
  { auth = ""
  , secret = ""
  }

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

app : StartApp.App Model
app =
  start
    { init = (model, Effects.none)
    , update = update
    , inputs = [Signal.map Incoming <| dropRepeats server.signal]
    }

port serve : Task x Server
port serve =
  let
    _ = Debug.log "env" <| getEnv ()
  in
    createServer'
      server.address
      8080
      "Listening on 8080"

port reply : Signal (Task Effects.Never ())
port reply =
  app.tasks

(=>) = (,)
