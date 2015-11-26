module Client.StartTakeHome.Views where

import Html exposing (a, div, form, label, input, text, button, Html)
import Html.Attributes exposing (for, id, type', name, action, method, enctype, attribute, href)
import String

import Client.Components exposing (..)
import Shared.Test exposing (..)
import Shared.User exposing (..)
import Shared.Routes exposing (..)


startTestButton : Html
startTestButton =
    button
        [ ]
        [ text "Start test" ]

beforeTestWelcome : User -> TestEntry -> Html
beforeTestWelcome user test =
    form
        [ action routes.startTest
        , method "POST"
        , enctype "multipart/form-data"
        ]
        [ text <| "Welcome " ++ user.name ++ " "
        , text <| "You signed up to take the " ++ test.name ++ " take home!"
        , hiddenTokenField user.token
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

viewUploadSolution : User -> Html
viewUploadSolution user =
    form
        [ action routes.apply
        , method "POST"
        , enctype "multipart/form-data"
        ]
        [ fileField
        , hiddenTokenField user.token
        , submitField
        ]


viewTakeHome : User -> TestEntry -> Html
viewTakeHome user test =
    let
        testView =
            case test.itemType of
                TestLink ->
                    viewTestLink test
                TestFile ->
                    viewTestFile test
    in
        div
            []
            [ testView
            , viewUploadSolution user
            ]
