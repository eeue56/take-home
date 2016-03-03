module Shared.Routes (Route(..), matchRoute, routePath, routes, matchStyle, matchFile, Style(..), File(..), stylePath, filePath) where

{-| Static routes and assets for use with views and routing
-}

import RouteParser exposing (Matcher, static, dyn1, string)
import Client.Styles
import Client.Admin.Styles
import Client.Signup.Styles
import Client.StartTakeHome.Styles


{-| These routes allow you to keep all your paths in one place
and use them elsewhere, and be reminded when you delete them!
-}
type Route
    = Index
    | Apply
    | SignUp
    | StartTest
    | Login
    | RegisterUser
    | Swimlanes
    | ViewSingleUser
    | StyleAsset String
    | FileAsset String
    | NotFound String

routes : List (Matcher Route)
routes =
    [ static Index "/"
    , static Apply "/apply"
    , static SignUp "/signup"
    , static StartTest "/start-test"
    , static Login "/login"
    , static RegisterUser "/admin/registerUser"
    , static Swimlanes "/swim"
    , static ViewSingleUser "/admin/viewUser"
    , dyn1 StyleAsset "/styles/" string ""
    , dyn1 FileAsset "/files/" string ""
    ]

routePath : Route -> String
routePath route =
    case route of
        Index -> "/"
        Apply -> "/apply"
        SignUp -> "/signup"
        StartTest -> "/start-test"
        Login -> "/login"
        RegisterUser -> "/admin/registerUser"
        Swimlanes -> "/swim"
        ViewSingleUser -> "/admin/viewUser"
        -- This should never happen
        _ -> "/404"

matchRoute : String -> Route
matchRoute url =
    RouteParser.match routes url
        |> Maybe.withDefault (NotFound url)


{-| Right now, we only consider CSS assets that we care about
The route should be the path refered to in the view, the
CSS should be the CSS, as a string
-}
type alias StyleConfig =
    { route : String
    , css : String
    }

type Style
    = AdminStyle
    | SignupStyle
    | StartStyle
    | MainStyle

styles : List StyleConfig
styles =
    [ { route = "admin.css", css = Client.Admin.Styles.css }
    , { route = "signup.css", css = Client.Signup.Styles.css }
    , { route = "start.css", css = Client.StartTakeHome.Styles.css }
    , { route = "styles.css", css = Client.Styles.css }
    ]

stylePath : Style -> String
stylePath tag =
    "/styles/" ++
        case tag of
            AdminStyle -> "admin.css"
            SignupStyle -> "signup.css"
            StartStyle -> "start.css"
            MainStyle -> "main.css"

matchStyle : String -> Maybe StyleConfig
matchStyle url =
    List.filter (\style -> style.route == url) styles
        |> List.head


type alias FileConfig =
    { route : String
    , file : String
    }

type File = LogoFile

files : List FileConfig
files =
    [ { route = "noredink.svg", file = "/Client/images/noredink.svg" }
    ]

filePath : File -> String
filePath tag =
    "/files/" ++
        case tag of
            LogoFile -> "noredink.svg"

matchFile : String -> Maybe FileConfig
matchFile url =
    List.filter (\style -> style.route == url) files
        |> List.head
