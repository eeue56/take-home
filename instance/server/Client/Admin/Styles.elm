module Client.Admin.Styles (..) where

import Client.Styles exposing (colors)
import Stylesheets exposing (..)
import Client.Styles exposing (..)


css : String
css =
    Stylesheets.prettyPrint 4
        <| stylesheet
        |%| ul
        |-| backgroundColor colors.white
        |-| boxSizing borderBox
        |-| padding 12 px
        |.| TestInProgress
        |-| backgroundColor colors.turquoise
        |.| TestFinishedInTime
        |-| backgroundColor colors.green
        |.| TestFinishedLate
        |-| backgroundColor colors.purple
        |.| TestNotTaken
        |-| backgroundColor colors.white
