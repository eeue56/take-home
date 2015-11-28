module Shared.User where

import Json.Decode exposing (Value, Decoder, succeed, (:=), string, maybe, value, customDecoder)
import Json.Decode.Extra exposing (apply)
import Converters exposing (deserialize)
import Moment exposing (Moment)

(|:) = Json.Decode.Extra.apply

type alias User =
    { token : String
    , name : String
    , email : String
    , role : String
    , startTime : Maybe Moment
    , endTime : Maybe Moment
    , submissionLocation : Maybe Moment
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

{-| Decode a Maybe Moment
-}
decodeMaybeMoment : Decoder (Maybe Moment)
decodeMaybeMoment =
    customDecoder value (\val -> Ok (deserialize val))


decoder : Decoder User
decoder =
    succeed User
        |: ("token" := string)
        |: ("name" := string)
        |: ("email" := string)
        |: ("role" := string)
        |: ("startTime" := decodeMaybeMoment)
        |: ("endTime" := decodeMaybeMoment)
        |: ("submissionLocation" := decodeMaybeMoment)
