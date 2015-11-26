module Shared.Test where

import Json.Decode exposing (Decoder, succeed, (:=), string, list)
import Json.Decode.Extra exposing (apply)

(|:) = Json.Decode.Extra.apply

type alias TestEntry =
    { name : String
    , itemType : String
    , item : String }

type alias TestConfig =
    { tests : List TestEntry
    }

testEntryDecoder : Decoder TestEntry
testEntryDecoder =
    succeed TestEntry
        |: ("name" := string)
        |: ("item" := string)
        |: ("itemType" := string)

testConfigDecoder : Decoder TestConfig
testConfigDecoder =
    succeed TestConfig
        |: ("tests" := list testEntryDecoder)
