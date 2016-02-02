module Client.Styles (..) where

import Helpers exposing (namespace)
import Shared.User exposing (..)
import Css exposing (..)
import Css.Elements exposing (..)


globalNamespace = namespace "global"
{ id, class, classList } = globalNamespace


getCss =
    (\x -> x.css) << compile << stylesheet globalNamespace

type CssClasses
    = Field
    | TestFinishedLate
    | TestFinishedInTime
    | TestInProgress
    | TestNotTaken

    | Button

    | Swimlane
    | SwimlaneContainer

    | SwimlaneInProgress
    | SwimlaneNotStarted
    | SwimlaneDone
    | SwimlaneUsername
    | SwimlaneUser
    | SwimlaneUserBar

    | SwimlaneInitials

    | Welcome
    | WelcomeMessageName

    | SignupFormContainer
    | InputField


type CssIds
    = PasswordId


colors =
    { black = hex "333333"
    , grayDarker = hex "7A787A"
    , white = hex "fff"
    , green = hex "3BD867"
    , greenLighter = hex "C4F3D1"
    , greenLightest = hex "E2F9E8"
    , turquoise = hex "08CFCB"
    , turquoiseLighter = hex "B4F0EF"
    , turquoiseLightest = hex "DAF8F7"
    , coral = hex "FF997B"
    , coralLighter = hex "FFE0D7"
    , coralLightest = hex "FFF0EB"
    , orange = hex "F7A700"
    , purple = hex "8E62A7"
    , purpleLighter = hex "DDCFE4"
    , purpleLightest = hex "EEE8F2"
    }


userClassesBasedOnTime user =
    let
        startedTestEver =
            hasStartedTest user

        inProgress =
            hasTestInProgress user

        finishedLate =
            hasFinishedTestLate user

        finishedInTime =
            hasFinishedTestInTime user
    in
        classList
            [ ( TestInProgress, inProgress )
            , ( TestFinishedLate, finishedLate )
            , ( TestFinishedInTime, finishedInTime )
            , ( TestNotTaken, not startedTestEver )
            ]

swimlaneWidth =
    450

swimlaneLeft : Int -> Mixin
swimlaneLeft number =
    let
        gap =
            50 + (5 * number)
        shift =
            swimlaneWidth * number
    in
        gap + shift
            |> px
            |> left

initialsStyle : Color -> Color -> Css.StyleBlock
initialsStyle background main =
    (.) SwimlaneUser
        [ children
            [ (.) SwimlaneInitials
                [ backgroundColor background
                , color main
                ]
            , (.) SwimlaneUsername
                [ backgroundColor background
                , color main
                ]
            , (.) SwimlaneUserBar
                [ backgroundColor main
                ]
            ]
        ]



css : String
css =
    getCss
        [ (.) Button
            [ padding (px 15)
            , color colors.white
            , backgroundColor colors.green
            , textDecoration none
            , verticalAlign middle
            , display inlineBlock
            ]
        , (.) Swimlane
            [ height (px 880)
            , position absolute
            , top (px 50)
            , px swimlaneWidth |> width
            , border2 (px 4) solid
            , borderRadius4 (px 5) (px 5) (px 15) (px 15)
            , overflow hidden
            , boxSizing borderBox
            ]
        , (.) SwimlaneNotStarted
            [ backgroundColor colors.purpleLighter
            , borderColor colors.purple
            , swimlaneLeft 0
            , children [ initialsStyle colors.purple colors.purpleLightest ]
            ]
        , (.) SwimlaneInProgress
            [ backgroundColor colors.turquoiseLighter
            , borderColor colors.turquoise
            , swimlaneLeft 1
            , children [ initialsStyle colors.turquoise colors.turquoiseLightest ]
            ]
        , (.) SwimlaneDone
            [ backgroundColor colors.greenLighter
            , borderColor colors.green
            , swimlaneLeft 2
            , children [ initialsStyle colors.green colors.greenLightest ]
            ]
        , (.) SwimlaneInitials
            [ width (px 50)
            , height (px 50)
            , property "float" "left"
            , property "font-size" "36px"
            , property "line-height" "1.4"
            , textAlign center
            ]
        , (.) SwimlaneUsername
            [ height (px 50)
            , property "font-size" "36px"
            , property "line-height" "1.2"
            , property "font-style" "italic"
            , textAlign center
            ]
        , (.) SwimlaneUser
            [ width (pct 100)
            , height (px 50)
            , marginBottom (px 10)
            ]
        , (.) SwimlaneUserBar
            [ width (px 10)
            , height (px 50)
            , property "float" "left"
            ]
        , (.) Welcome
            [ padding (px 50)
            , marginLeft (px 50)
            , marginTop (px 50)
            ]
        ]

