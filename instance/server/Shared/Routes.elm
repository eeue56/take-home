module Shared.Routes (routes) where

type alias Routes =
    { apply : String
    , index : String
    , signup : String
    , startTest : String
    , login : String
    }

routes =
    { apply = "/apply"
    , index = "/"
    , signup = "/signup"
    , startTest = "/start-test"
    , login = "/login"
    }
