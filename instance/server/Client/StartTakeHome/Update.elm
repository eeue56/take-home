module Client.StartTakeHome.Update (..) where

import Client.StartTakeHome.Model exposing (Model)
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

        UpdateTime moment ->
            ( { model | currentTime = moment }, Effects.none )
