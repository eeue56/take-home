module Http.Request (Method(..), Query(..), Form, FormFile, Request, encodeUri, emptyReq, onCloseReq, parseQuery, getQueryField, getFormFiles, getFormField, setForm) where

{-| Stuff for dealing with requests
# Handle Requests
@docs Request, emptyReq

@docs Method

# Events

@docs onCloseReq
-}

import Task exposing (Task)
import Http.Listeners exposing (on)

import Native.Http


{-| Standard Http Methods, useful for routing
-}
type Method
    = GET
    | POST
    | PUT
    | DELETE
    | NOOP


type Query
    = Query


type alias FormFile =
    { fieldName : String
    , originalFilename : String
    , path : String
    , size : Int
    }


type Form
    = Form


{-| Node.js native Request object
[Node Docs](https://nodejs.org/api/http.html#http_http_incomingmessage)
-}
type alias Request =
    { url : String
    , method : Method
    , body : String
    , form : Form
    }


{-| `emptyReq` is a dummy Native Request object incase you need it, as the initial value of
a `Signal.Mailbox` for example.
-}
emptyReq : Request
emptyReq =
    { url = ""
    , method = NOOP
    , body = ""
    , form = Form
    }


{-| "Close" events as a Signal for Request objects.
[Node docs](https://nodejs.org/api/http.html#http_event_close_2)
-}
onCloseReq : Request -> Signal ()
onCloseReq =
    on "close"

encodeUri : String -> String
encodeUri =
    Native.Http.encodeUri

parseQuery : String -> Result String Query
parseQuery =
    Native.Http.parseQuery


getQueryField : String -> Query -> Maybe a
getQueryField =
    Native.Http.getQueryField


getFormField : String -> Form -> Maybe a
getFormField =
    Native.Http.getFormField


getFormFiles : Form -> List FormFile
getFormFiles =
    Native.Http.getFormFiles


setForm : Request -> Task a Request
setForm =
    Native.Http.setForm
