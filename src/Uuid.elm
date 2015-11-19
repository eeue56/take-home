module Uuid (v1, v4) where

import Task exposing (Task)

import Native.Uuid


v1 : Task x String
v1 =
    v1Wrapper ()


v1Wrapper : () -> Task x String
v1Wrapper =
    Native.Uuid.v1


v4 : Task x String
v4 =
    v4Wrapper ()


v4Wrapper : () -> Task x String
v4Wrapper =
    Native.Uuid.v4
