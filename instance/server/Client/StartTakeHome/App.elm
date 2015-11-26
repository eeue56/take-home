module Client.StartTakeHome.App where

import Html exposing (a, div, form, label, input, text, button, Html)
import Html.Attributes exposing (for, id, type', name, action, method, enctype, attribute, href)
import String

import Client.Components exposing (..)
import Shared.Test exposing (..)
import Shared.User exposing (..)
import Shared.Routes exposing (..)
import Client.StartTakeHome.Model exposing (Model)
import Client.StartTakeHome.Update exposing (update, Action(..))
import Client.StartTakeHome.Views exposing (..)
import Effects

import Time exposing (..)

import Telate exposing (loadObject)
import Moment
import StartApp exposing (App, start)

config =
    loadObject "TelateProps"
        |> Maybe.withDefault
            { user = emptyUser
            , test = emptyTestEntry}

model =
    config

app : App Model Action
app =
    start
        { init = (model, Effects.none)
        , update = update
        , inputs = [ eachSecond ]
        }

eachSecond =
    every second
        |> Signal.map (\_ -> UpdateTime (Moment.getCurrent ()))

main =
    Signal.map (viewTakeHome app.address) app.model
