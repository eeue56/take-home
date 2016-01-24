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
    250

swimlaneLeft : Int -> Mixin
swimlaneLeft n =
    let
        number =
            n + 1
        gap =
            50
        shift =
            swimlaneWidth * (number - 1)
    in
        gap + shift
            |> px
            |> left


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
            [ height (px 500)
            , position absolute
            , top (px 50)
            , px swimlaneWidth |> width
            , border2 (px 4) solid
            , overflow hidden
            , boxSizing borderBox
            ]
        , (.) SwimlaneNotStarted
            [ backgroundColor colors.purpleLighter
            , borderColor colors.purple
            , swimlaneLeft 0
            ]
        , (.) SwimlaneInProgress
            [ backgroundColor colors.turquoiseLighter
            , borderColor colors.turquoise
            , swimlaneLeft 1
            ]
        , (.) SwimlaneDone
            [ backgroundColor colors.greenLighter
            , borderColor colors.green
            , swimlaneLeft 2
            ]
        ]
