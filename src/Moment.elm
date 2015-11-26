module Moment (getCurrent,
    Moment(..), MomentRecord,
    format, formatString,
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

getCurrent : () -> Moment
getCurrent =
    Native.Moment.getCurrent

format : Moment -> String
format =
    Native.Moment.format

formatString : Moment -> String -> String
formatString =
    Native.Moment.formatString

toRecord : Moment -> MomentRecord
toRecord =
    Native.Moment.toRecord

fromRecord : MomentRecord -> Moment
fromRecord =
    Native.Moment.fromRecord
