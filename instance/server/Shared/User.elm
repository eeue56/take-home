module Shared.User (..) where

import Json.Decode exposing (Value, Decoder, succeed, (:=), string, maybe, value, customDecoder)
import Json.Decode.Extra exposing (apply)
import Converters exposing (deserialize)
import Moment exposing (Moment, emptyMoment)


(|:) =
    Json.Decode.Extra.apply


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

hasStartedTest : User -> Bool
hasStartedTest user =
    case user.startTime of
        Nothing -> False
        _ -> True

hasFinishedTest : User -> Bool
hasFinishedTest user =
    case user.endTime of
        Nothing -> False
        _ -> True

hasTestInProgress : User -> Bool
hasTestInProgress user =
    hasStartedTest user && not (hasFinishedTest user)

hasFinishedTestInTime : User -> Bool
hasFinishedTestInTime user =
    case (user.startTime, user.endTime) of
        (Just endTime, Just startTime) ->
            let
                withTwoHours =
                    Moment.add startTime { emptyMoment | hours = 2 }
            in
                Moment.isBefore endTime (withTwoHours)
        _ ->
            False

hasFinishedTestLate : User -> Bool
hasFinishedTestLate user =
    if hasFinishedTest user then
        not (hasFinishedTestInTime user)
    else
        False
