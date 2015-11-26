module Shared.User where

import Json.Decode exposing (Value, Decoder, succeed, (:=), string, maybe, value, customDecoder)
import Json.Decode.Extra exposing (apply)
import Converters exposing (deserialize)

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

emptyUser =
    { token = ""
    , name = ""
    , email = ""
    , role = ""
    , startTime = Nothing
    , endTime = Nothing
    , submissionLocation = Nothing}

decodeMaybe : Decoder (Maybe String)
decodeMaybe =
    customDecoder value (\val -> Ok (deserialize val))


decoder : Decoder User
decoder =
    succeed User
        |: ("token" := string)
        |: ("name" := string)
        |: ("email" := string)
        |: ("role" := string)
        |: ("startTime" := decodeMaybe)
        |: ("endTime" := decodeMaybe)
        |: ("submissionLocation" := decodeMaybe)
