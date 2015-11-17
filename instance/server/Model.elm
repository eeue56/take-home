module Model where

import Http.Request exposing (Request)
import Http.Response exposing (Response)

type alias Model =
  { auth : String
  , secret : String
  }

type alias Connection =
  (Request, Response)
