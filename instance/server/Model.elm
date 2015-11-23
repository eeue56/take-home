module Model where

import Http.Request exposing (Request)
import Http.Response exposing (Response)

import Database.Nedb exposing (Client)

type alias Model =
  { key : String
  , secret : String
  , bucket : String
  , baseUrl : String
  , database : Client
  }

type alias Connection =
  (Request, Response)

type alias SiteConfig =
  { myPort: Int
  , databaseConfig: String
  , accessKey: String
  , secret: String
  , bucket: String
  , baseUrl: String
  }
