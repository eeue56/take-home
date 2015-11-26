module Client.StartTakeHome.Model where

import Shared.User exposing (..)
import Shared.Test exposing (TestEntry)
import Moment exposing (Moment)

type alias Model =
    { user : User
    , test : TestEntry
    , currentTime : Moment
    }
