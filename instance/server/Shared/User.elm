module Shared.User where

import Json.Decode exposing (Value, Decoder, succeed, (:=), string, maybe, value, customDecoder)
import Json.Decode.Extra exposing (apply)
import Converters exposing (deserialize)
import Moment exposing (MomentRecord)

(|:) = Json.Decode.Extra.apply

type alias User =
    { token : String
    , name : String
    , email : String
    , role : String
    , startTime : Maybe MomentRecord
    , endTime : Maybe MomentRecord
    , submissionLocation : Maybe MomentRecord
    }

emptyUser =
    { token = ""
    , name = ""
    , email = ""
    , role = ""
    , startTime = Nothing
    , endTime = Nothing
    , submissionLocation = Nothing
    }

decodeMaybe : Decoder (Maybe MomentRecord)
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
