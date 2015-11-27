module Record (asDict) where
{-| Module for working with records

@docs asDict
-}

import Native.Record

{-| Placeholder. Take a record, convert it to a dict and use it as a dict instead
-}
asDict : a -> b
asDict =
    Native.Record.asDict
