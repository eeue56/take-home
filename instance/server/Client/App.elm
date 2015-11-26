module Client.App where

import Html exposing (form, label, input, text, div, a, Html)
import Html.Attributes exposing (for, id, type', name, action, method, enctype, value, href)

import Shared.User exposing (User)
import Client.Components exposing (..)

genericErrorView : a -> Html
genericErrorView err =
    text (toString err)

successView : String -> String -> Html
successView name url =
    div
        []
        [ text ("Your take home will be with you shortly, " ++ name)
        , a
            [ href url ]
            [ text "Click here to see what you uploaded" ]
        ]

index : Html
index =
    form
        [ action "/apply"
        , method "POST"
        , enctype "multipart/form-data"
        ]
        [ emailField
        , passwordField
        , fileField
        , submitField
        ]
