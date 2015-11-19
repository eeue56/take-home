module Generators where

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
import Http.Server exposing (randomUrl)


import Client.App exposing (successView, successfulSignupView)
import Model exposing (Connection, Model)

import Debug
import Maybe
import Result exposing (Result)
import Effects exposing (Effects)
import Dict
import Task exposing (Task, andThen)

import String

import Knox


--uploadFile : String -> String -> Knox.Client -> Task (Result String String) String
uploadFile fileName fileNameOnServer client =
  Knox.putFile fileName fileNameOnServer client


--generateSuccessPage : Response -> Request -> Model -> Task b ()
generateSuccessPage res req model =
  let
    client =
      Knox.createClient { key = model.key, secret = model.secret, bucket = model.bucket }

    newPath originalFilename =
      String.join "/"
        [ name
        , email
        , originalFilename
        ]

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
        [] -> Debug.log "no files" <| Task.succeed "failed"
        x::_ ->
          uploadFile x.path (newPath x.originalFilename) client

  in
    handleFiles `andThen` (\url -> writeNode (view url) res)

generateSignupPage : Response -> Request -> Model -> Task a ()
generateSignupPage res req model =
  let
    name : String
    name =
      getFormField "name" req.form
        |> Maybe.withDefault "anon"

    email : String
    email =
      getFormField "email" req.form
        |> Maybe.withDefault "anon"

    url =
      randomUrl False model.baseUrl

    view =
      successfulSignupView name url
  in
    writeNode view res
