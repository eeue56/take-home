module Json.Encode.Extra where

import Json.Encode as Json


objectFromList : List (List (String, Json.Value)) -> Json.Value
objectFromList =
    List.concat >> Json.object

maybe : (a -> Json.Value) -> String -> Maybe a ->  List (String, Json.Value)
maybe encoder name value =
    case value of
        Nothing ->
            []

        Just actualValue ->
            [ (name, encoder actualValue) ]
