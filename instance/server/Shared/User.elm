module Shared.User where

import Json.Decode exposing (Decoder, succeed, (:=), string, maybe)
import Json.Decode.Extra exposing (apply)

(|:) = Json.Decode.Extra.apply

type alias User =
    { token : String
    , name : String
    , email : String
    , role : String
    , startTime : Maybe String
    , endTime : Maybe String
    , submissionLocation : Maybe String
    }

decoder : Decoder User
decoder =
    succeed User
        |: ("token" := string)
        |: ("name" := string)
        |: ("email" := string)
        |: ("role" := string)
        |: ("startTime" := maybe string)
        |: ("endTime" := maybe string)
        |: ("submissionLocation" := maybe string)
