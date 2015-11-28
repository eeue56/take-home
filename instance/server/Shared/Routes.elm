module Shared.Routes (routes, assets) where

import Client.Admin.Styles

type alias Asset =
    { route : String
    , css : String
    }

type alias Routes =
    { apply : String
    , index : String
    , signup : String
    , startTest : String
    , login : String
    }

type alias Assets =
    { admin : Asset
    }

routes =
    { apply = "/apply"
    , index = "/"
    , signup = "/signup"
    , startTest = "/start-test"
    , login = "/login"
    }

assets =
    { admin =
        { route = "/admin/styles.css"
        , css = Client.Admin.Styles.css
        }
    }
