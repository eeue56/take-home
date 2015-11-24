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
import Http.Server

import Knox
import Database.Nedb as Database

import Client.App exposing (successView)
import Client.Signup.Views exposing (successfulSignupView, alreadySignupView)

import Model exposing (Connection, Model)
import User
import Shared.User exposing (User)
import Utils exposing (randomUrl)

import Debug
import Maybe
import Result exposing (Result)
import Effects exposing (Effects, Never(..))
import Dict
import Task exposing (Task)
import String

andThen = (flip Task.andThen)
onError = (flip Task.onError)


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
    handleFiles
      |> andThen (\url -> writeNode (view url) res)

insertUserIntoDatabase : String -> String -> String -> Database.Client -> Task (Maybe User) String
insertUserIntoDatabase name email url database =
  let
    userForSearching =
      { name = name
      , email = email
      }

    handleInsertErrors : List a -> Task (Maybe a) String
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
              |> onError (\_ -> Task.fail Nothing)
              |> Task.map (\_ -> url)
        x::_ ->
          Task.fail (Just x)
  in
    User.getUsers userForSearching database
      |> onError (\_ -> Task.fail Nothing)
      |> andThen handleInsertErrors


generateSignupPage : Response -> Request -> Model -> Task String ()
generateSignupPage res req model =
  let
    name =
      getFormField "name" req.form
        |> Maybe.withDefault "anon"
    email =
      getFormField "email" req.form
        |> Maybe.withDefault "anon"

    user =
      { name = name, email = email }

    getUrl =
      randomUrl False (model.baseUrl ++ "?token=")
  in
    getUrl
      |> andThen (\url -> insertUserIntoDatabase name email url model.database)
      |> Task.map (\url -> successfulSignupView { name = name, email = email, uniqueUrl = url } )
      |> onError (\maybeUser ->
        case maybeUser of
          Just user -> Task.succeed (alreadySignupView user)
          Nothing -> Task.fail "no such user"
        )
      |> andThen (\node -> writeNode node res)
