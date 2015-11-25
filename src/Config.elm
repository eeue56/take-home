module Config (loadConfig, unsureLoadConfig) where
{-| Load JSON as a config
Only works on node - `require` is both builtin and blocking on node
meaning no need for Tasks

@docs loadConfig, unsureLoadConfig
-}
import Json.Decode as Json
import Native.Config

{-| Load a given filename into a record
-}
loadConfig : String -> a
loadConfig =
    Native.Config.loadConfig

{-| Load a given filename into a Json value
-}
unsureLoadConfig : String -> Json.Value
unsureLoadConfig =
    Native.Config.loadConfig
