module Shared.User where

import Json.Decode exposing (Decoder, succeed, (:=), string)
import Json.Decode.Extra exposing (apply)

(|:) = Json.Decode.Extra.apply

type alias User =
    { token : String
    , name : String
    , email : String
    , role : String }

decoder : Decoder User
decoder =
    succeed User
        |: ("token" := string)
        |: ("name" := string)
        |: ("email" := string)
        |: ("role" := string)
