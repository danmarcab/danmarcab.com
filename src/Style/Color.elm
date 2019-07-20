module Style.Color exposing
    ( Scheme(..)
    , background
    , contentBackground
    , contentBorder
    , primary
    , secondaryText
    , text
    , white
    )

import Element exposing (Color)


type Scheme
    = Light
    | Dark


primary : Scheme -> Color
primary scheme =
    case scheme of
        Dark ->
            Element.rgb 0.1 0.1 0.1

        Light ->
            Element.rgb255 94 178 181


white : Color
white =
    Element.rgb255 255 255 255


background : Scheme -> Color
background scheme =
    case scheme of
        Dark ->
            Element.rgb 0.1 0.1 0.1

        Light ->
            Element.rgb255 215 234 235


contentBorder : Scheme -> Color
contentBorder scheme =
    case scheme of
        Dark ->
            Element.rgb 0.2 0.2 0.2

        Light ->
            Element.rgb255 150 150 150


contentBackground : Scheme -> Color
contentBackground scheme =
    case scheme of
        Dark ->
            Element.rgb 0.2 0.2 0.2

        Light ->
            Element.rgb255 250 250 250


text : Scheme -> Color
text scheme =
    case scheme of
        Dark ->
            Element.rgb 0.9 0.9 0.9

        Light ->
            Element.rgb 0.1 0.1 0.1


secondaryText : Scheme -> Color
secondaryText scheme =
    case scheme of
        Dark ->
            Element.rgb 0.9 0.9 0.9

        Light ->
            Element.rgb 0.4 0.4 0.4
