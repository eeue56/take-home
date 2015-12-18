module Client.Components (..) where

import Html exposing (form, label, input, text, div, a, Html)
import Html.Attributes exposing (for, type', name, id, attribute)
import Html.Helpers exposing (class)
import Client.Styles exposing (..)


labelFor : String -> String -> Html
labelFor id labelText =
    label
        [ for id ]
        [ text labelText ]


emailLabel =
    labelFor "email"


nameLabel =
    labelFor "name"


passwordLabel =
    labelFor "password"


emailField : Html
emailField =
    div
        [ class InputField ]
        [ label
            [ for "email" ]
            [ text "Email: " ]
        , input
            [ type' "text"
            , name "email"
            , id "email"
            ]
            []
        ]


nameField : Html
nameField =
    div
        [ class InputField ]
        [ label
            [ for "name" ]
            [ text "Full name: " ]
        , input
            [ type' "text"
            , name "name"
            , id "name"
            ]
            []
        ]


passwordField : Html
passwordField =
    div
        []
        [ label
            [ for "password" ]
            [ text "Password: " ]
        , input
            [ type' "password"
            , name "password"
            , id "password"
            ]
            []
        ]


submitField : Html
submitField =
    input
        [ type' "submit"
        , name "submit"
        , id "submit"
        , class Button
        ]
        []


fileField : Html
fileField =
    input
        [ type' "file"
        , name "file"
        , id "file"
        ]
        []


hiddenTokenField : String -> Html
hiddenTokenField token =
    input
        [ type' "hidden"
        , id "token"
        , name "token"
        , attribute "value" token
        ]
        []
