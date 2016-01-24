module Client.Admin.Styles (..) where

import Client.Styles exposing (..)
import Css exposing (..)
import Css.Elements exposing (ul)


css : String
css =
    getCss
        [ ul
            [ backgroundColor colors.white
            , boxSizing borderBox
            , padding (px 12)
            ]
        , (.) TestInProgress
            [ backgroundColor colors.turquoise
            ]
        , (.) TestFinishedInTime
            [ backgroundColor colors.green
            ]
        , (.) TestFinishedLate
            [ backgroundColor colors.purple
            ]
        , (.) TestNotTaken
            [ backgroundColor colors.white
            ]
        ]
