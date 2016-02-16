module Client.Components (..) where

import Html exposing (form, label, input, text, div, a, Html)
import Html.Attributes exposing (for, type', name, attribute, style)

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

initialsField : Html
initialsField =
    div
        [ class InitialsField ]
        [ label
            [ for "initials" ]
            [ text "Initials: " ]
        , input
            [ type' "text"
            , name "initials"
            , id "initials"
            ]
            []
        ]

applicationIdField : Html
applicationIdField =
    div
        [ class ApplicationIdField ]
        [ label
            [ for "applicationId" ]
            [ text "Application ID: " ]
        , input
            [ type' "text"
            , name "applicationId"
            , id "applicationId"
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

swimlane : Int -> Int -> List a -> Html
swimlane height width xs =
    let
        items = List.map (\item -> div [] [ text <| toString item]) xs
    in
        div
            [ class Swimlane
            , style
                [ ( "height", (toString height) ++ "px" )
                , ( "width", (toString width) ++ "px" )
                ]
            ]
            items
