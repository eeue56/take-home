module Main where

import Http.Server exposing (..)

import Http.Response.Write exposing
  ( writeHtml, writeJson
  , writeElm, writeFile
  , writeNode, writeRedirect)

import Http.Request exposing (emptyReq)
import Http.Response exposing (emptyRes)

import Signal exposing (dropRepeats, Mailbox, mailbox)

import Router exposing (..)
import Model exposing (..)

import StartApp exposing (start)
import Env

import Dict
import Task exposing (..)
import Effects exposing (Effects)

-- TODO use Maybe.Extra for this
(?) : Maybe a -> a -> a
(?) mx x = Maybe.withDefault x mx

model =
  { key = ""
  , secret = ""
  , bucket = ""
  }


envToModel env =
  { key =
      Dict.get "S3_AUTH" env ? ""

  , secret =
      Dict.get "S3_SECRET" env ? ""

  , bucket =
      Dict.get "S3_BUCKET" env ? ""

  , baseUrl =
      Dict.get "BASE_URL" env ? ""
  }

server : Mailbox Connection
server = mailbox (emptyReq, emptyRes)


init : Task Effects.Never StartAppAction
init =
  Env.getEnv ()
    |> Task.map (\env -> Init (envToModel env))

translateModel : (Model, Effects.Effects Action) -> (Maybe Model, Effects.Effects StartAppAction)
translateModel (model, action) =
  (Just model, Effects.map Update action)

updateWrapper : StartAppAction -> Maybe Model -> (Maybe Model, Effects.Effects StartAppAction)
updateWrapper startAppAction maybeModel =
  case (startAppAction, maybeModel) of

    (Update actualAction, Just actualModel) ->
      update actualAction actualModel
        |> translateModel

    (Init actualModel, _) ->
      (Just actualModel, Effects.none)

    _ ->
      (maybeModel, Effects.none)

app : StartApp.App (Maybe Model)
app =
  start
    { init = (Nothing, Effects.task init)
    , update = updateWrapper
    , inputs = [Signal.map (Update << Incoming) <| dropRepeats server.signal]
    }


port serve : Task x Server
port serve =
    createServer'
      server.address
      8080
      "Listening on 8080"

port reply : Signal (Task Effects.Never ())
port reply =
    app.tasks

