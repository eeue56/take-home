module Tasks where

import Task exposing (Task)
import Greenhouse

getUsersFromGreenhouse : Task String (List Greenhouse.User)
getUsersFromGreenhouse =
    Greenhouse.getUsers "" 1 100
