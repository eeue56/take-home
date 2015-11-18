module Router where

import Http.Response.Write exposing (writeHtml
  , writeJson
  , writeElm, writeFile
  , writeNode, writeRedirect)

import Http.Request exposing (emptyReq
  , Request, Method(..)
  , parseQuery, getQueryField
  , getFormField, getFormFiles
  , setForm
  )

import Http.Response exposing (Response)

import Model exposing (Connection, Model)
import Client.App exposing (index, successView)

import Task exposing (..)
import Signal exposing (..)
import Json.Encode as Json
import Maybe
import Result
import Effects exposing (Effects)
import Dict
import String

import Env
import Knox
import Converters

import Debug

type Action
  = Incoming Connection
  | Run ()
  | Noop

type StartAppAction
  = Init Model
  | Update Action


uploadFile : String -> String -> Model -> Task a (Result String String)
uploadFile fileName fileNameOnServer model =
  Knox.createClient { key = model.key, secret = model.secret, bucket = model.bucket }
    |> Knox.putFile fileName fileNameOnServer


generateSuccessPage : Response -> Request -> Model -> Task a ()
generateSuccessPage res req model =
  let
    name =
      getFormField "name" req.form
        |> Maybe.withDefault "anon"

    email =
      getFormField "email" req.form
        |> Maybe.withDefault "anon"

    view =
      successView name

    handleFiles =
      case getFormFiles req.form of
        [] -> Debug.log "no files" <| Task.succeed (Err "no file")
        x::_ ->
          let
            newPath =
              String.join "/"
                [ name
                , email
                , x.originalFilename
                ]
          in
            uploadFile x.path newPath model

  in
    handleFiles `andThen` (\_ -> writeNode view res)

routeIncoming : Connection -> Model -> (Model, Effects Action)
routeIncoming (req, res) model =
  case req.method of
    GET ->
      case req.url of
        "/" ->
          model =>
            (writeNode index res
              |> Task.map Run
              |> Effects.task)
        url ->
          model =>
            (writeFile url res
              |> Task.map Run
              |> Effects.task)

    POST ->
      case req.url of
        "/apply" ->
          model =>
            (setForm req
              |> (flip andThen) (\req -> generateSuccessPage res req model)
              |> Task.map Run
              |> Effects.task)
        _ ->
          model => Effects.none

    NOOP ->
      model => Effects.none

    _ ->
      model =>
        (writeJson (Json.string "unknown method!") res
          |> Task.map Run
          |> Effects.task)


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Incoming connection -> routeIncoming connection model
    Run _ -> (model, Effects.none)
    Noop -> (model, Effects.none)


(=>) = (,)
