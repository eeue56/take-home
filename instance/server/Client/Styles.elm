module Client.Styles (..) where

import Stylesheets exposing (..)
import Html.Helpers exposing (typedClassList)

import Shared.User exposing (..)


type CssClasses
    = Field
    | TestFinishedLate
    | TestFinishedInTime
    | TestInProgress
    | TestNotTaken

type CssIds =
    PasswordId

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
        typedClassList
            [ ( TestInProgress, inProgress )
            , ( TestFinishedLate, finishedLate )
            , ( TestFinishedInTime, finishedInTime )
            , ( TestNotTaken, not startedTestEver )
            ]
