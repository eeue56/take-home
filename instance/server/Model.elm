module Model (..) where

import Shared.Test exposing (TestConfig)
import Http.Request exposing (Request)
import Http.Response exposing (Response)
import Database.Nedb exposing (Client)
import Dict exposing (Dict)
import Github


type alias GithubInfo =
    { auth : Github.Auth
    , org : String
    , repo : String
    , assignee : String
    }

type alias Model =
    { key : String
    , secret : String
    , bucket : String
    , baseUrl : String
    , database : Client
    , testConfig : TestConfig
    , authSecret : String
    , greenhouseId : Int
    , contact : String
    , sessions : Dict String Session
    , github : GithubInfo
    , checklists : Dict String String
    }

type alias Session =
    { token : String }


type alias Connection =
    ( Request, Response )


type alias SiteConfig =
    { myPort : Int
    , databaseConfig : String
    , testConfig : String
    , accessKey : String
    , secret : String
    , bucket : String
    , baseUrl : String
    , authSecret : String
    , greenhouseId : String
    , contact : String
    }
