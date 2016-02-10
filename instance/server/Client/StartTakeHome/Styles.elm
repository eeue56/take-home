module Client.StartTakeHome.Styles where

import Shared.User exposing (..)
import Css exposing (..)
import Css.Elements exposing (..)
import Client.Styles exposing (..)

fontSizing =
    property "font-size" "76px"

css : String
css =
    getCss
        [ (.) Welcome
            [ padding (px 50)
            , marginLeft (px 50)
            , marginTop (px 50)
            ]
        , (.) WelcomeTestName
            [ fontSizing
            , property "line-height" "1.4"
            ]
        , (.) Button
            [ property "font-size" "36px"
            , padding (px 15)
            , color colors.white
            , backgroundColor colors.green
            , textDecoration none
            , verticalAlign middle
            , display inlineBlock
            , borderColor colors.greenLighter
            ]
        ]
