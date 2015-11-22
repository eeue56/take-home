module Shared.User where

import Json.Decode exposing (Decoder, succeed, (:=), string)
import Json.Decode.Extra exposing (apply)

(|:) = Json.Decode.Extra.apply

type alias User =
    { uniqueUrl : String
    , name : String
    , email : String }

decoder : Decoder User
decoder =
    succeed User
        |: ("uniqueUrl" := string)
        |: ("name" := string)
        |: ("email" := string)
