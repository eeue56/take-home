module Client.App where

import Html exposing (form, label, input, text, div, Html)
import Html.Attributes exposing (for, id, type', name, action, method, enctype, value)
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
        , enctype "multipart/form-data"
        ]
        [ label
            [ for "email" ]
            [ text "Email: " ]
        , input
            [ type' "text"
            , name "email"
            , id "email"
            , value "sdfghjk"
            ]
            [ ]
        ,label
            [ for "name" ]
            [ text "Full name: " ]
        ,input
            [ type' "text"
            , name "name"
            , id "name"
            , value "zxcvbnm"
            ]
            [ ]
        , input
            [ type' "file"
            , name "file"
            , id "file" ]
            [ ]
        ,input
            [ type' "submit"
            , name "submit"
            , id "submit"
            ]
            [ text "Submit" ]
        ]
