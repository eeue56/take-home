module Config where

import Native.Config

loadConfig : String -> a
loadConfig =
    Native.Config.loadConfig
