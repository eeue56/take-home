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

{-| Load a config from a json file
This will die at compile time if the file is missing
-}
myConfig : SiteConfig
myConfig =
  loadConfig "./config/config.json"

{-| load up our test configs based on where our main
config tells us where it's kept
-}
testConfig : TestConfig
testConfig =
  Test.loadConfig myConfig.testConfig

{-| Our server model
-}
model : Model
model =
  { key = ""
  , secret = ""
  , bucket = ""
  , baseUrl = ""
  , contact = ""
  , database = Database.createClientFromConfigFile myConfig.databaseConfig
  , testConfig = testConfig
  , authSecret = ""
  }

{-| Grab properties from ENV for use in our model
-}
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

  , contact =
      Dict.get myConfig.contact env ? ""

  , database =
      model.database

  , testConfig =
      model.testConfig
  }

{-| Our actual server is just a mailbox
-}
server : Mailbox Connection
server = mailbox (emptyReq, emptyRes)

{-| Load the current Env on startup and populate the model
-}
init : Task Effects.Never StartAppAction
init =
  Env.getCurrent
    |> Task.map (\env -> Init (envToModel env))

{-| Wrap the model
-}
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

{-| This uses a slightly modified start-app with anything binding it to
HTML removed, and the address exposed
-}
app : App (Maybe Model) StartAppAction
app =
  start
    { init = (Nothing, Effects.task init)
    , update = updateWrapper
    , inputs = [Signal.map (Update << Incoming) <| dropRepeats server.signal]
    }

{-| Create the server through using the ports hack
-}
port serve : Task x Server
port serve =
    createServerAndListen
      server.address
      myConfig.myPort
      ("Listening on " ++ (toString myConfig.myPort))

{-| Standard port for running tasks with StartApp
-}
port reply : Signal (Task Effects.Never ())
port reply =
    app.tasks

