module Moment (getCurrent, Moment, emptyMoment, format, formatString, add, subtract, from, isBefore, isAfter) where

import Native.Moment
import Native.MomentJS


type alias Moment =
    { years : Int
    , months : Int
    , date : Int
    , hours : Int
    , minutes : Int
    , seconds : Int
    , milliseconds : Int
    }


emptyMoment =
    { years = 0
    , months = 0
    , date = 0
    , hours = 0
    , minutes = 0
    , seconds = 0
    , milliseconds = 0
    }

{-| Get the current the moment
-}
getCurrent : () -> Moment
getCurrent =
    Native.Moment.getCurrent

{-| Call the default `Moment.js` format method
-}
format : Moment -> String
format =
    Native.Moment.format


formatString : String -> Moment -> String
formatString =
    Native.Moment.formatString


add : Moment -> Moment -> Moment
add =
    Native.Moment.add


subtract : Moment -> Moment -> Moment
subtract =
    Native.Moment.subtract


from : Moment -> Moment -> String
from =
    Native.Moment.from

{-| Returns `True` if the first `Moment` is before the second
-}
isBefore : Moment -> Moment -> Bool
isBefore =
    Native.Moment.isBefore

{-| Returns `True` if the first `Moment` is after the second
-}
isAfter : Moment -> Moment -> Bool
isAfter =
    Native.Moment.isAfter
