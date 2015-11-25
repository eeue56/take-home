module Http.Listeners (on) where
{-| Module for event listener helpers

@docs on
-}

import Native.Http

{-| Wrapper for creating event listeners
-}
on : String -> target -> Signal input
on = Native.Http.on
