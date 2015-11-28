module Shared.Test (..) where

import Json.Decode exposing (Decoder, succeed, (:=), string, list, customDecoder)
import Json.Decode.Extra exposing (apply)
import String


(|:) =
    Json.Decode.Extra.apply


type TestType
    = TestFile
    | TestLink
    | NoTest


type alias TestEntry =
    { name : String
    , item : String
    , itemType : TestType
    }


emptyTestEntry =
    { name = ""
    , item = ""
    , itemType = NoTest
    }


type alias TestConfig =
    { tests : List TestEntry
    }


testEntryByName : String -> TestConfig -> List TestEntry
testEntryByName name config =
    List.filter (\test -> test.name == name) config.tests


testTypeDecoder : Decoder TestType
testTypeDecoder =
    customDecoder
        string
        (\value ->
            case String.toLower value of
                "file" ->
                    Ok TestFile

                "link" ->
                    Ok TestLink

                _ ->
                    Err "Must be file or link"
        )


testEntryDecoder : Decoder TestEntry
testEntryDecoder =
    succeed TestEntry
        |: ("name" := string)
        |: ("item" := string)
        |: ("itemType" := testTypeDecoder)


testConfigDecoder : Decoder TestConfig
testConfigDecoder =
    succeed TestConfig
        |: ("tests" := list testEntryDecoder)
