module Html.Tags (..) where

import Json.Encode exposing (string)
import VirtualDom exposing (Node, property)
import Html.Attributes exposing (attribute, href, action)
import Html exposing (div, Html)
import Shared.Routes exposing (Route, toPath)


style : String -> Html
style text =
    VirtualDom.node
        "style"
        [ property "textContent" <| string text
        , property "type" <| string "text/css"
        ]
        []


stylesheetLink : String -> Html
stylesheetLink url =
    VirtualDom.node
        "link"
        [ property "rel" (string "stylesheet")
        , property "type" (string "text/css")
        , property "href" (string url)
        ]
        []

hrefLink =
    href << toPath

actionLink =
    action << toPath
