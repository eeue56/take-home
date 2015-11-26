module Main where

import Http.Server exposing (..)

import Http.Request exposing (emptyReq)
import Http.Response exposing (emptyRes)
import StartApp exposing (App, start)

import Database.Nedb as Database
import Config exposing (loadConfig)
import Env

import Signal exposing (dropRepeats, Mailbox, mailbox)
import Dict
import Task exposing (..)
import Effects exposing (Effects)

import Shared.Test exposing (TestConfig)

import Router exposing (..)
import Model exposing (..)
import Test



-- TODO use Maybe.Extra for this
(?) : Maybe a -> a -> a
(?) mx x = Maybe.withDefault x mx

myConfig : SiteConfig
myConfig =
  loadConfig "./config/config.json"

testConfig : TestConfig
testConfig =
  Test.loadConfig myConfig.testConfig

model : Model
model =
  { key = ""
  , secret = ""
  , bucket = ""
  , baseUrl = ""
  , database = Database.createClientFromConfigFile myConfig.databaseConfig
  , testConfig = testConfig
  , authSecret = ""
  }


envToModel env =
  { key =
      Dict.get myConfig.accessKey env ? ""

  , secret =
      Dict.get myConfig.secret env ? ""

  , bucket =
      Dict.get myConfig.bucket env ? ""

  , baseUrl =
      Dict.get myConfig.baseUrl env ? ""

  , authSecret =
      Dict.get myConfig.authSecret env ? ""

  , database =
      model.database

  , testConfig =
      model.testConfig
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

app : App (Maybe Model) StartAppAction
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
      myConfig.myPort
      ("Listening on " ++ (toString myConfig.myPort))

port reply : Signal (Task Effects.Never ())
port reply =
    app.tasks

