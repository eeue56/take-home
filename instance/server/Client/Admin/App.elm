module Client.Admin.App (..) where

import Shared.Test exposing (..)
import Shared.User exposing (..)
import Shared.Routes exposing (..)
import Client.Admin.Model exposing (Model)
import Client.Admin.Update exposing (update, Action(..))
import Client.Admin.Views exposing (..)
import Effects
import Time exposing (..)
import Telate exposing (loadObject)
import StartApp exposing (App, start)


config =
    loadObject "TelateProps"
        |> Maybe.withDefault { }


model =
    config


app : App Model Action
app =
    start
        { init = ( model, Effects.none )
        , update = update
        , inputs = [ ]
        }
