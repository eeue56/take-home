module Shared.Routes (Route(..), toPath, routes, assets) where

{-| Static routes and assets for use with views and routing
-}

import RouteParser exposing (Matcher, static)
import Client.Styles
import Client.Admin.Styles
import Client.Signup.Styles
import Client.StartTakeHome.Styles


{-| Right now, we only consider CSS assets that we care about
The route should be the path refered to in the view, the
CSS should be the CSS, as a string
-}
type alias Asset =
    { route : String
    , css : String
    }

type alias Image =
    { route : String
    , file : String
    }


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

{-| Let's take the routes approach, but also store our CSS in there!
-}
type alias Assets =
    { admin : Asset
    , main : Asset
    , signup : Asset
    , start : Asset
    , noredinkLogo : Image
    }

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

toPath : Route -> String
toPath route =
    case route of
        Index -> "/"
        Apply -> "/apply"
        SignUp -> "/signup"
        StartTest -> "/start-test"
        Login -> "/login"
        RegisterUser -> "/admin/registerUser"
        Swimlanes -> "/swim"
        ViewSingleUser -> "/admin/viewUser"

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
