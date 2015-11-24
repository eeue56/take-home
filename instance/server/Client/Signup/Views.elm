module Client.Signup.Views where

import Html exposing (form, label, input, text, div, a, Html)
import Html.Attributes exposing (for, id, type', name, action, method, enctype, value, href)

import Shared.User exposing (User)
import Client.Components exposing (..)

signUpForTakeHomeView : Html
signUpForTakeHomeView =
    form
        [ action "/signup"
        , method "POST"
        , enctype "multipart/form-data"
        ]
        [ emailField
        , passwordField
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
