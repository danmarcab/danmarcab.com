module ViewSettings exposing (Size(..), ViewSettings, forSize)

import Element exposing (DeviceClass(..), Orientation(..))


type alias Color =
    Element.Color


type Size
    = Small
    | Medium
    | Large


type alias ViewSettings =
    { font : FontSettings
    , spacing : Sizes
    , color : ColorSettings
    , device : Element.Device
    , size : Size
    }


type alias FontSettings =
    { size : Sizes
    , color : FontColorSettings
    }


type alias FontColorSettings =
    { primary : Color
    , secondary : Color
    , tertiary : Color
    , error : Color
    }


type alias ColorSettings =
    { primary : Color
    , secondary : Color
    , tertiary : Color
    , mainBackground : Color
    , contentBackground : Color
    , shadow : Color
    , innerShadow : Color
    }


type alias Sizes =
    { xs : Int
    , sm : Int
    , md : Int
    , lg : Int
    , xl : Int
    }


forSize : Int -> Int -> ViewSettings
forSize width height =
    forDevice <| Element.classifyDevice { width = width, height = height }


forDevice : Element.Device -> ViewSettings
forDevice device =
    case device.class of
        Phone ->
            case device.orientation of
                Portrait ->
                    settings Small device

                Landscape ->
                    settings Small device
                        |> (\s -> { s | size = Medium })

        Tablet ->
            case device.orientation of
                Portrait ->
                    settings Medium device

                Landscape ->
                    settings Medium device
                        |> (\s -> { s | size = Large })

        Desktop ->
            settings Large device

        BigDesktop ->
            settings Large device


settings : Size -> Element.Device -> ViewSettings
settings size device =
    { size = size
    , device = device
    , font =
        { color = fontColorSettings
        , size = fontSizes size
        }
    , spacing = spacing size
    , color = colorSettings
    }


fontSizes : Size -> Sizes
fontSizes size =
    case size of
        Small ->
            { xs = 10
            , sm = 12
            , md = 14
            , lg = 16
            , xl = 19
            }

        Medium ->
            { xs = 12
            , sm = 14
            , md = 16
            , lg = 19
            , xl = 22
            }

        Large ->
            { xs = 14
            , sm = 16
            , md = 20
            , lg = 24
            , xl = 30
            }


spacing : Size -> Sizes
spacing size =
    case size of
        Small ->
            { xs = 2
            , sm = 5
            , md = 8
            , lg = 15
            , xl = 30
            }

        Medium ->
            { xs = 3
            , sm = 5
            , md = 10
            , lg = 20
            , xl = 40
            }

        Large ->
            { xs = 5
            , sm = 10
            , md = 20
            , lg = 40
            , xl = 80
            }


colorSettings : ColorSettings
colorSettings =
    { primary = Element.rgb 0 0 0
    , secondary = Element.rgb 0.3 0.3 0.3
    , tertiary = Element.rgb 0.6 0.6 0.6
    , mainBackground = Element.rgb255 245 243 242
    , contentBackground = Element.rgb 1 1 1
    , shadow = Element.rgb 0.8 0.8 0.8
    , innerShadow = Element.rgb 0.9 0.9 0.9
    }


fontColorSettings : FontColorSettings
fontColorSettings =
    { primary = Element.rgb 0.2 0.2 0.2
    , secondary = Element.rgb 0.4 0.4 0.4
    , tertiary = Element.rgb 0.6 0.6 0.6
    , error = Element.rgb 0.9 0.2 0.2
    }
