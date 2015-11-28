module Http.Response (Response, StatusCode, Header, emptyRes, okCode, redirectCode, textHtml, applicationJson, textCss, redirectHeader, onCloseRes, onFinishRes) where

import Http.Listeners exposing (on)


{-| An http header, such as content type
-}
type alias Header =
    ( String, String )


{-| StatusCode ie 200 or 404
-}
type alias StatusCode =
    Int


{-| Node.js native Response object
[Node Docs](https://nodejs.org/api/http.html#http_class_http_serverresponse)
-}
type alias Response =
    { statusCode : StatusCode }


{-| `emptyRes` is a dummy Native Response object incase you need it, as the initial value of
a `Signal.Mailbox` for example.
-}
emptyRes : Response
emptyRes =
    { statusCode = 418 }


{-| Html Header {"Content-Type":"text/html"}
-}
textHtml : Header
textHtml =
    ( "Content-Type", "text/html" )


{-| Html Header {"Content-Type":"text/css"}
-}
textCss : Header
textCss =
    ( "Content-Type", "text/css" )


{-| Json Header {"Content-Type":"application/json"}
-}
applicationJson : Header
applicationJson =
    ( "Content-Type", "application/json" )


{-| "Close" events as a Signal for Response objects.
[Node docs](https://nodejs.org/api/http.html#http_event_close_1)
-}
onCloseRes : Response -> Signal ()
onCloseRes =
    on "close"


{-| "Finsh" events as a Signal for Reponse objects.
[Node docs](https://nodejs.org/api/http.html#http_event_finish)
-}
onFinishRes : Response -> Signal ()
onFinishRes =
    on "finish"


redirectCode : StatusCode
redirectCode =
    302


okCode : StatusCode
okCode =
    200


redirectHeader : String -> Header
redirectHeader url =
    ( "Location", url )
