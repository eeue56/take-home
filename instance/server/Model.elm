module Model where

import Http.Request exposing (Request)
import Http.Response exposing (Response)

type alias Model =
  { key : String
  , secret : String
  , bucket : String
  }

type alias Connection =
  (Request, Response)
