module Config exposing (Config, desktopSpacing, lightModeColors)

import Element exposing (Color)


type alias Config =
    { colors : Colors
    , spacing : Spacing
    }


type alias Spacing =
    { tiny : Int
    , small : Int
    , medium : Int
    , large : Int
    , extraLarge : Int
    }


type alias Colors =
    { text : Color
    , secondaryText : Color
    , tertiaryText : Color
    , contentBackground : Color
    , primary : Color
    , mainBackground : Color
    , headerBackground : Color
    , headerText : Color
    }


lightModeColors : Colors
lightModeColors =
    { text = Element.rgb 0.1 0.1 0.1
    , secondaryText = Element.rgb 0.4 0.4 0.4
    , tertiaryText = Element.rgb255 150 150 150
    , contentBackground = Element.rgb255 250 250 250
    , primary = Element.rgb255 94 178 181
    , mainBackground = Element.rgb255 215 234 235
    , headerBackground = Element.rgb255 94 178 181
    , headerText = Element.rgb255 255 2552 255
    }


desktopSpacing : Spacing
desktopSpacing =
    { tiny = 5
    , small = 10
    , medium = 20
    , large = 40
    , extraLarge = 80
    }
