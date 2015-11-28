module Test (..) where

import Json.Decode as Json
import Config exposing (loadConfigIntoValue)
import Shared.Test exposing (..)


{-| Load a config from a given filename
If it fails to parse correctly, return a `TestConfig` with no `tests`
-}
loadConfig : String -> TestConfig
loadConfig filename =
    loadConfigIntoValue filename
        |> Json.decodeValue testConfigDecoder
        |> (\value ->
                case value of
                    Err err ->
                        { tests = [] }

                    Ok v ->
                        v
           )
