module Random.Impure where

import Task exposing (Task)
import Native.Random.Impure


get : () -> Task String Float
get _ =
    Native.Random.Impure.get ()


withinRange : Int -> Int -> Task String Int
withinRange lower upper =
    get ()
        |> Task.map (\x ->
            x * (toFloat <| upper - lower)
                |> floor
                |> (\y -> y + lower)
            )
