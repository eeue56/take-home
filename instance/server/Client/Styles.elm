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
    , turquoise = hex "08CFCB"
    , purple = hex "8E62A7"
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
            [ padding (px 25)
            , height (px 500)
            , width (px 250)
            , backgroundColor colors.green
            ]
        , (.) SwimlaneInProgress
            [ backgroundColor colors.turquoise
            ]
        , (.) SwimlaneNotStarted
            [ backgroundColor colors.purple
            ]
        ]
