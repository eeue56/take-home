module Client.Admin.Update (..) where

import Client.Admin.Model exposing (Model)
import Effects
import Moment exposing (Moment)


type Action
    = Noop
    | UpdateTime Moment


update : Action -> Model -> ( Model, Effects.Effects Action )
update action model =
    case action of
        Noop ->
            ( model, Effects.none )
