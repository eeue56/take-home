module Telate (loadObject) where

import Native.Telate


loadObject : String -> a
loadObject =
    Native.Telate
