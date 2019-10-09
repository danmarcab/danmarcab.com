module ViewSettings exposing (ViewSettings, default)

import Element


type alias Color =
    Element.Color


type alias ViewSettings =
    { font : FontSettings
    , spacing : Sizes
    , color : ColorSettings
    }


type alias FontSettings =
    { size : Sizes
    , color :
        { primary : Color
        , secondary : Color
        , tertiary : Color
        }
    }


type alias ColorSettings =
    { primary : Color
    , secondary : Color
    , tertiary : Color
    , mainBackground : Color
    , contentBackground : Color
    , shadow : Color
    }


type alias Sizes =
    { xs : Int
    , sm : Int
    , md : Int
    , lg : Int
    , xl : Int
    }


default : ViewSettings
default =
    { font =
        { color =
            { primary = Element.rgb 0.2 0.2 0.2
            , secondary = Element.rgb 0.4 0.4 0.4
            , tertiary = Element.rgb 0.6 0.6 0.6
            }
        , size =
            { xs = 14
            , sm = 16
            , md = 20
            , lg = 24
            , xl = 30
            }
        }
    , spacing =
        { xs = 5
        , sm = 10
        , md = 20
        , lg = 40
        , xl = 80
        }
    , color =
        { primary = Element.rgb 0 0 0
        , secondary = Element.rgb 0.3 0.3 0.3
        , tertiary = Element.rgb 0.6 0.6 0.6
        , mainBackground = Element.rgb255 245 243 242
        , contentBackground = Element.rgb 1 1 1
        , shadow = Element.rgb 0.8 0.8 0.8
        }
    }
