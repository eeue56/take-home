module Html.Helpers (..) where

import Html.Attributes as Attr


class str =
    Attr.class (toString str)


typedClassList xs =
    List.map (\(x,y) -> (toString x, y)) xs
        |> Attr.classList


id str =
    Attr.id (toString str)


style =
    Attr.style
