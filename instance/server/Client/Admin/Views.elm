module Client.Admin.Views where


import Html exposing (..)
import Html.Attributes exposing (for, id, type', name, action, method, enctype, attribute, href)
import String

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

allUsersView : List User -> Html
allUsersView users =
    List.map (\user -> li [] [ text user.name ]) users
        |> ul []
