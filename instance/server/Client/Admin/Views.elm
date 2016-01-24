module Client.Admin.Views (..) where

import Html exposing (..)
import Html.Attributes exposing (for, id, type', name, action, method, enctype, attribute, href)
import Html.Tags exposing (style, stylesheetLink)

import String
import Dict
import Record
import Client.Components exposing (..)
import Client.Styles exposing (..)
import Shared.Test exposing (..)
import Shared.User exposing (..)
import Shared.Routes exposing (..)


loginView =
    form
        [ action routes.login
        , method "POST"
        , enctype "multipart/form-data"
        ]
        [ stylesheetLink assets.main.route
        , passwordLabel "Please enter the admin password"
        , passwordField
        , submitField
        ]


usersSwimlanes : (List User) -> Html
usersSwimlanes users =
    let
        usersNotStarted =
            List.filter (not << hasStartedTest) users
        usersInProgress =
            List.filter (hasTestInProgress) users
        usersDone =
            List.filter (hasFinishedTest) users
    in
        div
            [ class SwimlaneContainer ]
            [ stylesheetLink assets.main.route
            , userSwimlane SwimlaneNotStarted usersNotStarted
            , userSwimlane SwimlaneInProgress usersInProgress
            , userSwimlane SwimlaneDone usersDone
            ]

userSwimlane : CssClasses -> List User -> Html
userSwimlane classType users =
    let
        usersView =
            List.map (\user -> div [] [ text user.name ]) users
    in
    div
        [ classList
            [ (classType, True)
            , (Swimlane, True)
            ]
        ]
        usersView



linkToRegisterView : Html
linkToRegisterView =
    a
        [ href routes.registerUser
        , class Button
        ]
        [ text "Click here to register a new user" ]


registerUserView : Html
registerUserView =
    form
        [ action routes.registerUser
        , method "POST"
        , enctype "multipart/form-data"
        ]
        [ emailLabel "Please enter the email for the canidate"
        , emailField
        , submitField
        ]


successfulRegistrationView : String -> User -> Html
successfulRegistrationView url user =
    div
        []
        [ div [] [ text "Please send this url to the candidate" ]
        , a
            [ href url ]
            [ text url ]
        ]


userView : User -> Html
userView user =
    Record.asDict user
        |> Dict.toList
        |> List.map
            (\( field, value ) ->
                li [] [ text (field ++ " : " ++ (toString value)) ]
            )
        |> ul
            [ userClassesBasedOnTime user ]


allUsersView : List User -> Html
allUsersView users =
    div
        []
        [ stylesheetLink assets.main.route
        , stylesheetLink assets.admin.route
        , linkToRegisterView
        , List.map (\user -> li [] [ userView user ]) users
            |> ul []
        ]
