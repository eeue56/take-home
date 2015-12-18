module Client.Signup.Styles (..) where

import Client.Styles exposing (colors)
import Stylesheets exposing (..)
import Client.Styles exposing (..)


css : String
css =
    Stylesheets.prettyPrint 4
        <| stylesheet
            |.| SignupFormContainer
                |-| width 300 px
            |.| InputField
                |-| width 100 pct
                |-| marginTop 10 px
                |%| input
                    |-| width 100 pct