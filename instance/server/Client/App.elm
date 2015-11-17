module Client.App where

import Html exposing (form, label, input, text, div, Html)
import Html.Attributes exposing (for, id, type', name, action, method)
import Json.Encode as Encode


successView : String -> Html
successView name =
    div
        []
        [ text ("Your take home will be with you shortly, " ++ name)]

index : Html
index =
    form
        [ action "/apply"
        , method "POST"
        ]
        [ label
            [ for "email" ]
            [ text "Email: " ]
        , input
            [ type' "text"
            , name "email"
            , id "email"
            ]
            [ ]
        ,label
            [ for "name" ]
            [ text "Full name: " ]
        ,input
            [ type' "text"
            , name "name"
            , id "name"
            ]
            [ ]
        ,input
            [ type' "submit"
            , name "submit"
            , id "submit"
            ]
            [ text "Submit" ]
        ]
