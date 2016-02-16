module Client.StartTakeHome.Styles where

import Shared.User exposing (..)
import Css exposing (..)
import Css.Elements exposing (..)
import Client.Styles exposing (..)

fontSizing =
    property "font-size" "76px"

flexCenter =
    (.) Welcome
        [ children
            [ selector "*"
                [ property "display" "flex"
                , property "justify-content" "center"
                , property "align-items" "center"
                ]
            ]
        ]

css : String
css =
    getCss
        [ flexCenter
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
