module Env where

import Dict exposing (Dict)

import Converters
import Native.Env


getEnv : () -> Dict String String
getEnv =
    Native.Env.getEnv
