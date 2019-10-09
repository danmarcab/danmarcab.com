module Widget.Icon exposing (..)

import Element exposing (Color, Element)
import Element.Font as Font
import FeatherIcons as Icon exposing (Icon)


view : { size : Int, color : Color } -> Icon -> Element msg
view { size, color } icon =
    icon
        |> Icon.withSize (toFloat size)
        |> Icon.toHtml []
        |> Element.html
        |> Element.el [ Font.color color ]
