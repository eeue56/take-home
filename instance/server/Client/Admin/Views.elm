module Client.Admin.Views where

import Html exposing (..)
import Html.Attributes exposing (for, id, type', name, action, method, enctype, attribute, href)
import Html.Tags exposing (style, stylesheetLink)

import String
import Dict

import Record

import Client.Components exposing (..)
import Shared.Test exposing (..)
import Shared.User exposing (..)
import Shared.Routes exposing (..)


loginView =
    form
        [ action routes.login
        , method "POST"
        , enctype "multipart/form-data"
        ]
        [ passwordField
        , submitField
        ]

userView : User -> Html
userView user =
    Record.asDict user
        |> Dict.toList
        |> List.map
            (\(field, value) ->
                li [] [ text ((field) ++ " : " ++ (toString value)) ]
            )
        |> ul []

allUsersView : List User -> Html
allUsersView users =
    div
        []
        [ stylesheetLink assets.admin.route
        , List.map (\user -> li [] [ userView user ]) users
            |> ul []
        ]

