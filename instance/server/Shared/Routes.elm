module Shared.Routes (Route(..), match, routePath, routes, assets) where

{-| Static routes and assets for use with views and routing
-}

import RouteParser exposing (Matcher, static)
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

match : String -> Route
match url =
    RouteParser.match routes url
        |> Maybe.withDefault (NotFound url)


{-| Let's take the routes approach, but also store our CSS in there!
-}
type alias Assets =
    { admin : Style
    , main : Style
    , signup : Style
    , start : Style
    , noredinkLogo : File
    }

{-| Right now, we only consider CSS assets that we care about
The route should be the path refered to in the view, the
CSS should be the CSS, as a string
-}
type alias Style =
    { route : String
    , css : String
    }

type alias File =
    { route : String
    , file : String
    }

assets : Assets
assets =
    { admin =
        { route = "/admin/styles.css"
        , css = Client.Admin.Styles.css
        }
    , signup =
        { route = "/signup/styles.css"
        , css = Client.Signup.Styles.css
        }
    , start =
        { route = "/start/styles.css"
        , css = Client.StartTakeHome.Styles.css
        }
    , main =
        { route = "/styles.css"
        , css = Client.Styles.css
        }
    , noredinkLogo =
        { route ="/images/noredink.svg"
        , file = "/Client/images/noredink.svg"
        }
    }
