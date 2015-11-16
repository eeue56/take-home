module Main where

import Http.Server exposing (..)
import Http.Request exposing (emptyReq, Request, Method(..))
import Http.Response exposing (emptyRes, Response)
import Http.Response.Write exposing
  ( writeHtml, writeJson
  , writeElm, writeFile
  , writeNode, writeRedirect)

import Client.App exposing (index, successView)

import Task exposing (..)
import Signal exposing (..)
import Json.Encode as Json

server : Mailbox (Request, Response)
server = mailbox (emptyReq, emptyRes)

route : (Request, Response) -> Task x ()
route (req, res) =
  case req.method of
    GET ->
      case req.url of
        "/" ->
          writeNode index res
        "/success" ->
          writeNode successView res
        url ->
          writeFile url res

    POST ->
      case req.url of
        "/apply" ->
          writeRedirect "/success" res
        _ ->
          succeed ()

    NOOP ->
      succeed ()

    _ ->
      res |>
        writeJson (Json.string "unknown method!")

port reply : Signal (Task x ())
port reply = route <~ dropRepeats server.signal

port serve : Task x Server
port serve = createServer'
  server.address
  8080
  "Listening on 8080"
