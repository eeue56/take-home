module Main where

import Http.Server exposing (..)

import Http.Response.Write exposing
  ( writeHtml, writeJson
  , writeElm, writeFile
  , writeNode, writeRedirect)

import Http.Request exposing (emptyReq)
import Http.Response exposing (emptyRes)

import Signal exposing (dropRepeats, Mailbox, mailbox)

import Router exposing (..)
import Model exposing (..)
import StartApp exposing (start)
import Task exposing (..)
import Effects exposing (Effects)


model =
  { auth = ""
  , secret = ""
  }

server : Mailbox Connection
server = mailbox (emptyReq, emptyRes)

app : StartApp.App Model
app =
  start
    { init = (model, Effects.none)
    , update = update
    , inputs = [Signal.map Incoming <| dropRepeats server.signal]
    }


port serve : Task x Server
port serve =
    createServer'
      server.address
      8080
      "Listening on 8080"

port reply : Signal (Task Effects.Never ())
port reply =
    app.tasks

