module Env where

import Dict exposing (Dict)
import Task exposing (Task)

import Converters
import Native.Env

getEnv : () -> Task a (Dict String String)
getEnv =
    Native.Env.getEnv
