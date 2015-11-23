module Utils where

import Uuid
import Task exposing (Task)

{-| Generate a random url
Either time based or random
-}
randomUrl : Bool -> String -> Task x String
randomUrl isTimeBased base =
  let
    baseTask =
      if isTimeBased then
        Uuid.v1
      else
        Uuid.v4

    uuidToUrl uuid =
      base ++ uuid
  in
    baseTask
      |> Task.map uuidToUrl
