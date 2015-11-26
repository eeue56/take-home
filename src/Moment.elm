module Moment (getCurrent,
    Moment(..), MomentRecord,
    emptyMoment,
    format, formatString,
    add, subtract,
    toRecord, fromRecord) where

import Native.Moment
import Native.MomentJS

type Moment =
    Moment

type alias MomentRecord =
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

formatString : Moment -> String -> String
formatString =
    Native.Moment.formatString

add : MomentRecord -> Moment -> Moment
add =
    Native.Moment.add

subtract : MomentRecord -> Moment -> Moment
subtract =
    Native.Moment.subtract

toRecord : Moment -> MomentRecord
toRecord =
    Native.Moment.toRecord

fromRecord : MomentRecord -> Moment
fromRecord =
    Native.Moment.fromRecord
