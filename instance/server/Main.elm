module Main where

import Http.Server exposing (..)

import Http.Response.Write exposing
  ( writeHtml, writeJson
  , writeElm, writeFile
  , writeNode, writeRedirect)

import Http.Request exposing (emptyReq)
import Http.Response exposing (emptyRes)
import Http.Server.StartApp exposing (App, start)

import Database.Nedb as Database

import Env

import Signal exposing (dropRepeats, Mailbox, mailbox)
import Dict
import Task exposing (..)
import Effects exposing (Effects)

import Router exposing (..)
import Model exposing (..)


-- TODO use Maybe.Extra for this
(?) : Maybe a -> a -> a
(?) mx x = Maybe.withDefault x mx

model =
  { key = ""
  , secret = ""
  , bucket = ""
  , baseUrl = ""
  , database = Database.createClientFromConfigFile "./db_config.json"
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

  , database =
      model.database
  }

server : Mailbox Connection
server = mailbox (emptyReq, emptyRes)


init : Task Effects.Never StartAppAction
init =
  Env.getCurrent
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

app : App (Maybe Model)
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

