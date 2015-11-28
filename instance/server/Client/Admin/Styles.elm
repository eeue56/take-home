module Client.Admin.Styles (..) where


import Stylesheets exposing (..)

css : String
css =
    Stylesheets.prettyPrint 4 <|
        stylesheet
            |%| ul
                |-| backgroundColor (rgb 90 90 90)
                |-| boxSizing borderBox
                |-| padding 12 px
