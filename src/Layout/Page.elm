module Layout.Page exposing (view)

import Config exposing (Config)
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import FeatherIcons


view : Config -> { pageTitle : String, contentView : Element msg } -> Element msg
view config { pageTitle, contentView } =
    Element.column
        [ Element.width (Element.px 1000)
        , Element.centerX
        , Border.shadow
            { blur = 5
            , color = config.colors.tertiaryText
            , offset = ( 0, 0 )
            , size = 0
            }
        , Element.height Element.fill
        , Background.color config.colors.contentBackground
        , Font.color config.colors.text
        ]
        [ menuView config pageTitle
        , contentView
        , footerView config
        ]


menuView : Config -> String -> Element msg
menuView config pageTitle =
    Element.row
        [ Element.alignTop
        , Element.alignLeft
        , Element.paddingXY 20 10
        , Background.color config.colors.headerBackground
        , Font.color config.colors.headerText
        , Border.roundEach { topLeft = 0, topRight = 0, bottomLeft = 0, bottomRight = 10 }
        , Element.spacing 20
        , Font.size 25
        , Font.bold
        ]
        [ Element.link []
            { url = "/"
            , label =
                Element.el [] <| Element.text "danmarcab.com"
            }
        , divider config
        , Element.el [] <| Element.text pageTitle
        ]


divider : Config -> Element msg
divider config =
    Element.el
        [ Border.color config.colors.headerText
        , Border.width 1
        , Element.height Element.fill
        ]
        Element.none


footerView : Config -> Element msg
footerView config =
    Element.row
        [ Element.alignBottom
        , Element.alignRight
        , Element.paddingXY 20 10
        , Background.color config.colors.headerBackground
        , Font.color config.colors.headerText
        , Border.roundEach { topLeft = 10, topRight = 0, bottomLeft = 0, bottomRight = 0 }
        , Element.spacing 20
        , Font.size 18
        ]
        [ Element.text "© 2019 - present Daniel Marin Cabillas"
        , Element.link [] { url = "http://github.com/danmarcab", label = icon FeatherIcons.github }
        , Element.link [] { url = "http://twitter.com/danmarcab", label = icon FeatherIcons.twitter }
        ]


icon : FeatherIcons.Icon -> Element msg
icon i =
    i
        |> FeatherIcons.withSize 26
        |> FeatherIcons.withViewBox "0 0 26 26"
        |> FeatherIcons.toHtml []
        |> Element.html
        |> Element.el []
