module Client.Signup.Styles (..) where

import Css exposing (..)
import Css.Elements exposing (..)
import Client.Styles exposing (..)


css : String
css =
    getCss
        [ (.) SignupFormContainer
            [ width (px 300)
            ]
        , (.) InputField
            [ width (pct 100)
            , marginTop (px 10)
            , (with input)
                [ width (pct 100)
                ]
            ]
        ]
