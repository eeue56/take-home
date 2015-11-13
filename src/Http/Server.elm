module Http.Server
  ( createServer, createServer', listen
  , Port, Server
  , onRequest, onClose) where

{-| Simple bindings to Node.js's Http.Server

# Init the server

## Instaniation
@docs createServer, createServer'

## Actually listen
@docs listen

## Types
@docs Server, Port

# Listen for events
@docs onRequest, onClose
-}

import Task exposing (Task, succeed, andThen)
import Signal exposing (Address, Mailbox, mailbox)
import Json.Encode as Json

import Http.Request exposing (Request)
import Http.Response exposing (Response)
import Http.Listeners exposing (on)

import Native.Http

{-| Port number for the server to listen -}
type alias Port = Int


{-| Node.js native Server object
[Node Docs](https://nodejs.org/api/http.html#http_class_http_server) -}
type Server = Server

{-| "Request" events as a Signal.
[Node docs](https://nodejs.org/api/http.html#http_event_request) -}
onRequest : Server -> Signal (Request, Response)
onRequest = on "request"

{-| "Close" events as a Signal for Servers.
[Node docs](https://nodejs.org/api/http.html#http_event_close) -}
onClose : Server -> Signal ()
onClose = on "close"


{-| Create a new Http Server, and send (Request, Response) to an Address. For example

    port serve : Task x Server
    port serve = createServer server.address

[Node docs](https://nodejs.org/api/http.html#http_http_createserver_requestlistener)
-}
createServer : Address (Request, Response) -> Task x Server
createServer = Native.Http.createServer

{-| Create a Http Server and listen in one command! For example
    port serve : Task x Server
    port serve = createServer' server.address 8080 "Alive on 8080!"
-}

createServer' : Address (Request, Response) -> Port -> String -> Task x Server
createServer' address port' text  =
  createServer address `andThen` listen port' text

{-| Command Server to listen on a specific port,
    and echo a message to the console when active.
    Task will not resolve until listening is successful.
    For example

    port listen : Task x Server
    port listen = listen 8080 "Listening on 8080" server

[Node Docs](https://nodejs.org/api/http.html#http_server_listen_port_hostname_backlog_callback)
-}
listen : Port -> String -> Server -> Task x Server
listen = Native.Http.listen
