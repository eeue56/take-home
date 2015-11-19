module Env (getCurrent) where

import Dict exposing (Dict)
import Task exposing (Task)

import Converters
import Native.Env


getCurrent : Task x (Dict String String)
getCurrent =
    getCurrentWrapped ()

getCurrentWrapped : () -> Task x (Dict String String)
getCurrentWrapped =
    Native.Env.getEnv
