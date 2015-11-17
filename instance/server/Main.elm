module Main where

import Http.Server exposing (..)
import Http.Request exposing (emptyReq
  , Request, Method(..)
  , parseQuery, getQueryField
  , getFormField, getFormFiles
  , setForm
  )
import Http.Response exposing (emptyRes, Response)
import Http.Response.Write exposing
  ( writeHtml, writeJson
  , writeElm, writeFile
  , writeNode, writeRedirect)

import Client.App exposing (index, successView)

import Task exposing (..)
import Signal exposing (..)
import Json.Encode as Json
import Maybe
import Result

server : Mailbox (Request, Response)
server = mailbox (emptyReq, emptyRes)

generateSuccessPage : Response -> Request -> Task a ()
generateSuccessPage res req =
  let
    view =
      getFormField "name" req.form
        |> Maybe.withDefault "anon"
        |> successView
    in
      writeNode view res

route : (Request, Response) -> Task x ()
route (req, res) =
  case req.method of
    GET ->
      case req.url of
        "/" ->
          writeNode index res
        url ->
          writeFile url res

    POST ->
      case req.url of
        "/apply" ->
          setForm req
            |> (flip andThen) (generateSuccessPage res)
        _ ->
          succeed ()

    NOOP ->
      succeed ()

    _ ->
      res |>
        writeJson (Json.string "unknown method!")

port reply : Signal (Task x ())
port reply =
  route <~ dropRepeats server.signal

port serve : Task x Server
port serve =
  createServer'
    server.address
    8080
    "Listening on 8080"
