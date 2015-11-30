module Client.Styles (..) where


import Stylesheets exposing (..)


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
