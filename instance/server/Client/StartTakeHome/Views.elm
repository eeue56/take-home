module Client.StartTakeHome.Views where

import Html exposing (div, form, label, input, text, button, Html)
import Html.Attributes exposing (for, id, type', name, action, method, enctype, value, href)

import Client.Components exposing (..)
import Shared.Test exposing (..)
import Shared.User exposing (..)


startTestButton : Html
startTestButton =
    button
        []
        [ text "Start test" ]

beforeTestWelcome : User -> TestEntry -> Html
beforeTestWelcome user test =
    div
        []
        [ text <| "Welcome " ++ user.name ++ " "
        , text <| "You signed up to take the " ++ test.name ++ " take home!"
        ]
