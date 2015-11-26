module Client.StartTakeHome.Update where

import Client.StartTakeHome.Model exposing (Model)

import Effects

type Action =
    Noop

update : Action -> Model -> (Model, (Effects.Effects Action))
update action model =
    case action of
        Noop -> (model, Effects.none)
