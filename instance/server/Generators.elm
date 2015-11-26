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

import Client.App exposing (successView, genericErrorView)
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


generateSignupPage : Response -> Request -> Model -> Task String ()
generateSignupPage res req model =
  let
    name =
      getFormField "name" req.form
        |> Maybe.withDefault "anon"
    email =
      getFormField "email" req.form
        |> Maybe.withDefault "anon"

    role =
      getFormField "role" req.form
        |> Maybe.withDefault "none"

    searchUser =
      { name = name, email = email }

    getUrl =
      randomUrl False (model.baseUrl ++ "token=")

    tryInserting url =
      let
        userWithUrl =
          { name = name
          , email = email
          , uniqueUrl = url
          , role = role }
      in
        User.insertIntoDatabase userWithUrl model.database
          |> andThen (\_ -> Task.succeed (successfulSignupView userWithUrl))

  in
    User.getUsers { name = name, email = email } model.database
      |> andThen (\userList ->
        case userList of
            [] ->
                getUrl
                  |> andThen tryInserting
                  |> Task.mapError (\_ -> "no such user")

            existingUser :: [] ->
              Task.succeed (alreadySignupView existingUser)

            _ ->
              Task.fail "multiple users found with that name and email address"
        )
      |> andThen (\node -> writeNode node res)
