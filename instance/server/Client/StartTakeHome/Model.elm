module Client.StartTakeHome.Model where

import Shared.User exposing (..)
import Shared.Test exposing (TestEntry)

type alias Model =
    { user : User
    , test : TestEntry
    }
