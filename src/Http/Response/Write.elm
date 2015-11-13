module Http.Response.Write
  ( write, writeHead
  , writeHtml, writeJson
  , writeFile, writeElm
  , writeNode
  , end) where


import Native.Http.Response.Write
import Task exposing (Task, andThen)
import VirtualDom exposing (Node)
import Json.Encode as Json
import Http.Response exposing (textHtml, applicationJson, Header, Response, StatusCode)

{-| Write Headers to a Response
[Node Docs](https://nodejs.org/api/http.html#http_response_writehead_statuscode_statusmessage_headers) -}
writeHead : StatusCode -> Header -> Response -> Task x Response
writeHead = Native.Http.Response.Write.writeHead

{-| Write body to a Response
[Node Docs](https://nodejs.org/api/http.html#http_response_write_chunk_encoding_callback) -}
write : String -> Response -> Task x Response
write = Native.Http.Response.Write.write

{-| End a Response
[Node Docs](https://nodejs.org/api/http.html#http_response_end_data_encoding_callback) -}
end : Response -> Task x ()
end = Native.Http.Response.Write.end

writeAs : Header -> String -> Response -> Task x ()
writeAs header html res =
  writeHead 200 header res
  `andThen` write html `andThen` end

{-| Write out HTML to a Response. For example

    res `writeHtml` "<h1>Howdy</h1>"

 -}
writeHtml : String -> Response -> Task x ()
writeHtml = writeAs textHtml

{-| Write out JSON to a Response. For example
    res `writeJson` Json.object
      [ ("foo", Json.string "bar")
      , ("baz", Json.int 0) ]
-}
writeJson : Json.Value -> Response -> Task x ()
writeJson val res =
  writeAs applicationJson (Json.encode 0 val) res

{-| write a file -}
writeFile : String -> Response -> Task a ()
writeFile file res =
  writeHead 200 textHtml res
    `andThen` Native.Http.Response.Write.writeFile file
    `andThen` end

{-| write elm! -}
writeElm : String -> Response -> Task a ()
writeElm file res =
  writeHead 200 textHtml res
    `andThen` Native.Http.Response.Write.writeElm file
    `andThen` end

writeNode : Node -> Response -> Task a ()
writeNode node res =
  writeHead 200 textHtml res
    `andThen` Native.Http.Response.Write.writeNode node
    `andThen` end
