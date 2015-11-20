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
import User

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

insertUserIntoDatabase : String -> String -> String -> Database.Client -> Task (Maybe b) (String, String)
insertUserIntoDatabase name email url database =
  let
    user =
      { name = name
      , email = email
      }

    handleInsertErrors : List a -> Task (Maybe a) (String, String)
    handleInsertErrors userList =
      case userList of
        [] ->
          let
            userWithUrl =
              { name = name
              , email = email
              , uniqueUrl = url }
          in
            User.insertIntoDatabase userWithUrl database
              |> (flip Task.onError) (\_ -> Task.fail Nothing)
              |> Task.map (\id -> (url, id))
        x::_ ->
          Task.fail (Just x)
  in
    User.getUser user database
      |> (flip Task.onError) (\_ -> Task.fail Nothing)
      |> (flip Task.andThen) handleInsertErrors


generateSignupPage : Response -> Request -> Model -> Task String ()
generateSignupPage res req model =
  let
    name =
      getFormField "name" req.form
        |> Maybe.withDefault "anon"
    email =
      getFormField "email" req.form
        |> Maybe.withDefault "anon"
  in
    randomUrl False model.baseUrl
      |> (flip Task.andThen) (\url -> insertUserIntoDatabase name email url model.database)
      |> Task.map (\(url, _) -> successfulSignupView name url)
      |> (flip Task.onError) (\maybeUser ->
        case maybeUser of
          Just user -> Task.succeed (failedSignupView user.uniqueUrl)
          Nothing -> Task.fail "no such user"
        )
      |> (flip Task.andThen) (\node -> writeNode node res)
