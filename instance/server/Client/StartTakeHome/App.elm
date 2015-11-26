module Client.StartTakeHome.App where

import Html exposing (a, div, form, label, input, text, button, Html)
import Html.Attributes exposing (for, id, type', name, action, method, enctype, attribute, href)
import String

import Client.Components exposing (..)
import Shared.Test exposing (..)
import Shared.User exposing (..)
import Shared.Routes exposing (..)
import Client.StartTakeHome.Model exposing (Model)


import Telate exposing (loadObject)
import StartApp exposing (App, start)

user =
    loadObject "user"

test =
    loadObject "test"

model =
    { user = user
    , test = test
    }


app : App (Model ())
app =
    start
        { init = (model, Effects.none)
        , update = (\x -> (x, Effects.none))
        , inputs = []
        }

main =
    Signal.map (viewTakeHome app.address) app.model
