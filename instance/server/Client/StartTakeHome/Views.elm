module Client.StartTakeHome.Views where

import Html exposing (a, div, form, label, input, text, button, Html)
import Html.Attributes exposing (for, id, type', name, action, method, enctype, attribute, href)
import String

import Client.Components exposing (..)
import Shared.Test exposing (..)
import Shared.User exposing (..)


startTestButton : Html
startTestButton =
    button
        [ ]
        [ text "Start test" ]

beforeTestWelcome : User -> TestEntry -> Html
beforeTestWelcome user test =
    form
        [ action "/start-test"
        , method "POST"
        , enctype "multipart/form-data"
        ]
        [ text <| "Welcome " ++ user.name ++ " "
        , text <| "You signed up to take the " ++ test.name ++ " take home!"
        , input
            [ type' "hidden"
            , id "token"
            , name "token"
            , attribute "value" user.token
            ]
            []
        , startTestButton
        ]

viewTestLink : TestEntry -> Html
viewTestLink test =
    div
        [ ]
        [ a
            [ href test.item ]
            [ text "Click here to read the test contents!" ]
        ]

viewTestFile : TestEntry -> Html
viewTestFile test =
    let
        justFileName =
            case List.reverse (String.indexes "/" test.item) of
                [] -> test.item
                x::_ -> String.dropLeft (x + 1) test.item

    in
    div
        [ ]
        [ a
            [ href test.item
            , attribute "download" justFileName ]
            [ text "Click here to download the test content!" ]
        ]


viewTakeHome : TestEntry -> Html
viewTakeHome test =
    case test.itemType of
        TestLink ->
            viewTestLink test
        TestFile ->
            viewTestFile test
