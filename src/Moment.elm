module Moment (getCurrent, format, formatString) where

import Native.Moment

type Moment =
    Moment

getCurrent : () -> Moment
getCurrent =
    Native.Moment.getCurrent

format : Moment -> String
format =
    Native.Moment.format

formatString : Moment -> String -> String
formatString =
    Native.Moment.formatString
