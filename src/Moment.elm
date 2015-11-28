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


getCurrent : () -> Moment
getCurrent =
    Native.Moment.getCurrent


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


isBefore : Moment -> Moment -> Bool
isBefore =
    Native.Moment.isBefore


isAfter : Moment -> Moment -> Bool
isAfter =
    Native.Moment.isAfter
