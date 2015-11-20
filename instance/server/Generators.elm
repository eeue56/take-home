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

import Knox
import Database.Nedb as Database

import Client.App exposing (successView, successfulSignupView, failedSignupView)
import Model exposing (Connection, Model)

import Debug
import Maybe
import Result exposing (Result)
import Effects exposing (Effects, Never(..))
import Dict
import Task exposing (Task, andThen)
import String


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


userAlreadyExists user database =
  Database.find user database
    |> Task.map (not << List.isEmpty)

insertUserIntoDatabase : Request -> Model -> Task String String
insertUserIntoDatabase req model =
  let
    name =
      getFormField "name" req.form
        |> Maybe.withDefault "anon"

    email =
      getFormField "email" req.form
        |> Maybe.withDefault "anon"

    user =
      { name = name
      , email = email
      }
  in
    userAlreadyExists user model.database
      |> (flip Task.andThen) (\doesUserExist ->
        if doesUserExist then
          Task.fail "User already exists!"
        else
          Database.insert [user] model.database)


generateSignupPage : Response -> Request -> Model -> Task a ()
generateSignupPage res req model =
  let
    name : String
    name =
      getFormField "name" req.form
        |> Maybe.withDefault "anon"
  in
    insertUserIntoDatabase req model
      |> (flip Task.andThen) (\_ -> randomUrl False model.baseUrl)
      |> Task.map (successfulSignupView name)
      |> (flip Task.onError) (\_ -> Task.succeed failedSignupView)
      |> (flip Task.andThen) (\node -> writeNode node res)
