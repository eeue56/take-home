module Html.Tags (..) where

import Json.Encode exposing (string)
import VirtualDom exposing (Node, property)
import Html.Attributes exposing (attribute, href, action, src)
import Html exposing (div, Html, Attribute)
import Shared.Routes exposing (Route, routePath, Style, File, stylePath, filePath)


style : String -> Html
style text =
    VirtualDom.node
        "style"
        [ property "textContent" <| string text
        , property "type" <| string "text/css"
        ]
        []


stylesheetLink : Style -> Html
stylesheetLink tag =
    VirtualDom.node
        "link"
        [ property "rel" (string "stylesheet")
        , property "type" (string "text/css")
        , property "href" (string <| stylePath tag)
        ]
        []

hrefLink : Route -> Attribute
hrefLink =
    href << routePath

actionLink : Route -> Attribute
actionLink =
    action << routePath

srcLink : File -> Attribute
srcLink =
    src << filePath
