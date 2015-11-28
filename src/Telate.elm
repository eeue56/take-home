module Telate (loadObject) where

import Native.Telate


loadObject : String -> Maybe a
loadObject =
    Native.Telate.loadObject
