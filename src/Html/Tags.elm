module Html.Tags (..) where

import Json.Encode exposing (string)
import VirtualDom exposing (Node, property)
import Html.Attributes exposing (attribute, href, action, src)
import Html exposing (div, Html)
import Shared.Routes exposing (Route, routePath, Styles, stylePath, filePath)


style : String -> Html
style text =
    VirtualDom.node
        "style"
        [ property "textContent" <| string text
        , property "type" <| string "text/css"
        ]
        []


stylesheetLink : Styles -> Html
stylesheetLink tag =
    VirtualDom.node
        "link"
        [ property "rel" (string "stylesheet")
        , property "type" (string "text/css")
        , property "href" (string <| stylePath tag)
        ]
        []

hrefLink =
    href << routePath

actionLink =
    action << routePath

srcLink =
    src << filePath
