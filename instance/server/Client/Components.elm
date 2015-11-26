module Client.Components where

import Html exposing (form, label, input, text, div, a, Html)
import Html.Attributes exposing (..)


emailField : Html
emailField =
    div
        []
        [ label
            [ for "email" ]
            [ text "Email: " ]
        , input
            [ type' "text"
            , name "email"
            , id "email"
            ]
            [ ]
        ]

nameField : Html
nameField =
    div
        []
        [ label
            [ for "name" ]
            [ text "Full name: " ]
        , input
            [ type' "text"
            , name "name"
            , id "name"
            ]
            [ ]
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
            [ ]
        ]

submitField : Html
submitField =
    input
        [ type' "submit"
        , name "submit"
        , id "submit"
        ]
        [ ]

fileField : Html
fileField =
    input
        [ type' "file"
        , name "file"
        , id "file"
        ]
        [ ]

hiddenTokenField : String -> Html
hiddenTokenField token =
    input
        [ type' "hidden"
        , id "token"
        , name "token"
        , attribute "value" token
        ]
        []
