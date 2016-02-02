module Shared.Routes (routes, assets) where

{-| Static routes and assets for use with views and routing
-}

import Client.Styles
import Client.Admin.Styles
import Client.Signup.Styles


{-| Right now, we only consider CSS assets that we care about
The route should be the path refered to in the view, the
CSS should be the CSS, as a string
-}
type alias Asset =
    { route : String
    , css : String
    }


{-| These routes allow you to keep all your paths in one place
and use them elsewhere, and be reminded when you delete them!
-}
type alias Routes =
    { apply : String
    , index : String
    , signup : String
    , startTest : String
    , login : String
    , registerUser : String
    , swimlanes : String
    , viewSingleUser : String
    }


{-| Let's take the routes approach, but also store our CSS in there!
-}
type alias Assets =
    { admin : Asset
    , main : Asset
    }


routes =
    { apply = "/apply"
    , index = "/"
    , signup = "/signup"
    , startTest = "/start-test"
    , login = "/login"
    , registerUser = "/admin/registerUser"
    , swimlanes = "/swim"
    , viewSingleUser = "/admin/viewUser"
    }


assets =
    { admin =
        { route = "/admin/styles.css"
        , css = Client.Admin.Styles.css
        }
    , signup =
        { route = "/signup/styles.css"
        , css = Client.Signup.Styles.css
        }
    , main =
        { route = "/styles.css"
        , css = Client.Styles.css
        }
    }
