module Http.Request
  ( Method(..)
  , Request, emptyReq
  , onCloseReq
  ) where

{-| Stuff for dealing with requests
# Handle Requests
@docs Request, emptyReq

@docs Method

# Events

@docs onCloseReq
-}

import Http.Listeners exposing (on)

{-| Standard Http Methods, useful for routing -}
type Method
  = GET
  | POST
  | PUT
  | DELETE
  | NOOP


{-| Node.js native Request object
[Node Docs](https://nodejs.org/api/http.html#http_http_incomingmessage) -}
type alias Request =
  { url : String
  , method : Method }


{-| `emptyReq` is a dummy Native Request object incase you need it, as the initial value of
a `Signal.Mailbox` for example. -}
emptyReq : Request
emptyReq =
  { url = ""
  , method = NOOP }


{-| "Close" events as a Signal for Request objects.
[Node docs](https://nodejs.org/api/http.html#http_event_close_2) -}
onCloseReq : Request -> Signal ()
onCloseReq = on "close"


