module Client.StartTakeHome.Views where

import Html exposing (a, div, form, label, input, text, button, Html)
import Html.Attributes exposing (for, id, type', name, action, method, enctype, attribute, href)
import String

import Client.Components exposing (..)
import Shared.Test exposing (..)
import Shared.User exposing (..)
import Shared.Routes exposing (..)

import Client.StartTakeHome.Update exposing (Action)
import Client.StartTakeHome.Model exposing (Model)

import Moment exposing (emptyMoment, Moment)


startTestButton : Html
startTestButton =
    button
        [ ]
        [ text "Start test" ]

beforeTestWelcome : User -> TestEntry -> Html
beforeTestWelcome user test =
    form
        [ action routes.startTest
        , method "POST"
        , enctype "multipart/form-data"
        ]
        [ text <| "Welcome " ++ user.name ++ " "
        , text <| "You signed up to take the " ++ test.name ++ " take home!"
        , hiddenTokenField user.token
        , startTestButton
        ]

viewTestLink : TestEntry -> Html
viewTestLink test =
    div
        [ ]
        [ a
            [ href test.item ]
            [ text "Click here to read the test contents!" ]
        ]

viewTestFile : TestEntry -> Html
viewTestFile test =
    let
        justFileName =
            case List.reverse (String.indexes "/" test.item) of
                [] -> test.item
                x::_ -> String.dropLeft (x + 1) test.item

    in
    div
        [ ]
        [ a
            [ href test.item
            , attribute "download" justFileName ]
            [ text "Click here to download the test content!" ]
        ]

viewUploadSolution : User -> Html
viewUploadSolution user =
    form
        [ action routes.apply
        , method "POST"
        , enctype "multipart/form-data"
        ]
        [ fileField
        , hiddenTokenField user.token
        , submitField
        ]

viewTimeStarted : Moment -> User -> Html
viewTimeStarted currentTime user =
    case user.startTime of
        Nothing ->
            div [] [ text "Not started yet!" ]
        Just time ->
            let
                withTwoHours =
                    { emptyMoment | hours = 2 }

                endTime =
                    Moment.fromRecord time
                        |> Moment.add withTwoHours

                timeLeft =
                    currentTime
                        |> Moment.toRecord
                        |> (flip Moment.subtract) (Moment.fromRecord time)
            in
                div
                    []
                    [ text <| "Started at " ++ (Moment.formatString "h:mm:ss a" <| Moment.fromRecord time)
                    , text <| "End time" ++ (Moment.formatString "h:mm:ss a" <| endTime)
                    , text <| "Time left" ++ (Moment.formatString "h:mm:ss a" <| timeLeft)
                    ]


viewTakeHome : Signal.Address Action -> Model -> Html
viewTakeHome address model =
    let
        testView =
            case model.test.itemType of
                TestLink ->
                    viewTestLink model.test
                TestFile ->
                    viewTestFile model.test
                NoTest ->
                    text "failed to find your test"
    in
        div
            []
            [ testView
            , viewUploadSolution model.user
            , viewTimeStarted model.currentTime model.user
            ]
