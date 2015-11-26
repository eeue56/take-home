module Client.Signup.Views where

import Html exposing (form, label, input, text, div, a, select, option, Html)
import Html.Attributes exposing (for, id, type', name, action, method, enctype, value, href)

import Shared.User exposing (User)
import Shared.Test exposing (TestConfig)

import Client.Components exposing (..)

signUpForTakeHomeView : TestConfig -> Html
signUpForTakeHomeView testConfig =
    form
        [ action "/signup"
        , method "POST"
        , enctype "multipart/form-data"
        ]
        [ emailField
        , nameField
        , chooseRole (List.map (\test -> test.name) testConfig.tests)
        , submitField
        ]

alreadySignupView : User -> Html
alreadySignupView user =
    div
        []
        [ text "You've already signed up!"
        , a
            [ href user.uniqueUrl ]
            [ text user.uniqueUrl ]
        ]

successfulSignupView : User -> Html
successfulSignupView user =
    div
        []
        [ a
            [ href user.uniqueUrl ]
            [ text ("You have successfully signed up," ++ user.name ) ]
        ]

chooseRole : List String -> Html
chooseRole choices =
    let
        roles =
            List.map
                (\role -> option [] [ text role ])
            choices
    in
        select
            [ id "role"
            , name "role"
            ]
            roles
