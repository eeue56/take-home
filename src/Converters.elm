module Converters where


import Dict exposing (Dict)
import Native.Converters


jsObjectToElmDict : a -> Dict String String
jsObjectToElmDict =
    Native.Converters.jsObjectToElmDict
