module Env (getCurrent) where

{-| Get environment variables!

@docs getCurrent
-}

import Dict exposing (Dict)
import Task exposing (Task)
import Converters
import Native.Env


{-| Get the current env settings as a dict of string string
-}
getCurrent : Task x (Dict String String)
getCurrent =
    getCurrentWrapped ()


getCurrentWrapped : () -> Task x (Dict String String)
getCurrentWrapped =
    Native.Env.getEnv
