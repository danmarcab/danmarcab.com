module Style.Color exposing
    ( Scheme(..)
    , background
    , contentBackground
    , contentBorder
    , contentFont
    , primary
    , titleBackground
    , titleFont
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


titleBackground : Scheme -> Color
titleBackground scheme =
    case scheme of
        Dark ->
            Element.rgb 0.3 0.3 0.3

        Light ->
            Element.rgb 0.7 0.7 0.7


titleFont : Scheme -> Color
titleFont scheme =
    case scheme of
        Dark ->
            Element.rgb 0.9 0.9 0.9

        Light ->
            Element.rgb 0.1 0.1 0.1


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


contentFont : Scheme -> Color
contentFont scheme =
    case scheme of
        Dark ->
            Element.rgb 0.9 0.9 0.9

        Light ->
            Element.rgb 0.1 0.1 0.1
