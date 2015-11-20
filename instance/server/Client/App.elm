module Client.App where

import Html exposing (form, label, input, text, div, a, Html)
import Html.Attributes exposing (for, id, type', name, action, method, enctype, value, href)
import Json.Encode as Encode

genericErrorView : Html
genericErrorView =
    text "Something went wrong!"

successView : String -> String -> Html
successView name url =
    div
        []
        [ text ("Your take home will be with you shortly, " ++ name)
        , a
            [ href url ]
            [ text "Click here to see what you uploaded" ]
        ]


emailView : Html
emailView =
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

passwordView : Html
passwordView =
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

submitView : Html
submitView =
    input
        [ type' "submit"
        , name "submit"
        , id "submit"
        ]
        [ ]

signUpForTakeHomeView : Html
signUpForTakeHomeView =
    form
        [ action "/signup"
        , method "POST"
        , enctype "multipart/form-data"
        ]
        [ emailView
        , passwordView
        , submitView
        ]

failedSignupView : Html
failedSignupView =
    text "You've already signed up!"

successfulSignupView : String -> String -> Html
successfulSignupView name uniqueUrl =
    div
        []
        [ a
            [ href uniqueUrl ]
            [ text ("You have successfully signed up," ++ name ) ]
        ]


index : Html
index =
    form
        [ action "/apply"
        , method "POST"
        , enctype "multipart/form-data"
        ]
        [ emailView
        , passwordView
        , input
            [ type' "file"
            , name "file"
            , id "file" ]
            [ ]
        , submitView
        ]
