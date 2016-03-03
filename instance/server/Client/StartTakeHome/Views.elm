module Client.StartTakeHome.Views (..) where

import Html exposing (..)
import Html.Attributes exposing (src, for, id, type', name, action, method, enctype, attribute, href)
import Html.Tags exposing (style, stylesheetLink, actionLink, srcLink)
import String
import Client.Components exposing (..)
import Shared.Test exposing (..)
import Shared.User exposing (..)
import Shared.Routes exposing (Route(..), Style(..), File(..))
import Client.Styles exposing (..)
import Client.StartTakeHome.Update exposing (Action)
import Client.StartTakeHome.Model exposing (Model)
import Moment exposing (emptyMoment, Moment)



beforeTestWelcome : User -> TestEntry -> Html
beforeTestWelcome user test =
    div
        []
        [ stylesheetLink StartStyle
        , img
            [ srcLink LogoFile ]
            []
        , form
            [ class Welcome
            , actionLink StartTest
            , method "POST"
            , enctype "multipart/form-data"
            ]
            [ div
                [ class WelcomeMessageName ]
                [ text user.name ]
            , div
                [ class WelcomeTestName ]
                [ text <| test.name ]
            , hiddenTokenField user.token
            , button
                [ class Button ]
                [ text "Start the take home" ]
            ]
        ]

viewTestLink : TestEntry -> Html
viewTestLink test =
    div
        []
        [ a
            [ href test.item ]
            [ text "Click here to read the test contents!" ]
        ]


viewTestFile : TestEntry -> Html
viewTestFile test =
    let
        justFileName =
            case List.reverse (String.indexes "/" test.item) of
                [] ->
                    test.item

                x :: _ ->
                    String.dropLeft (x + 1) test.item
    in
        div
            []
            [ a
                [ href test.item
                , attribute "download" justFileName
                ]
                [ text "Click here to download the test content!" ]
            ]


viewUploadSolution : User -> Html
viewUploadSolution user =
    form
        [ actionLink Apply
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
                    Moment.add time withTwoHours

                timeLeft =
                    Moment.from endTime currentTime
            in
                div
                    []
                    [ text <| "Started at " ++ (Moment.formatString "h:mm:ss a" time)
                    , text <| "End time" ++ (Moment.formatString "h:mm:ss a" endTime)
                    , text <| "You should submit your solution " ++ timeLeft
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
                    text "Failed to find your test"
    in
        div
            []
            [ stylesheetLink MainStyle
            , testView
            , viewUploadSolution model.user
            , viewTimeStarted model.currentTime model.user
            ]
