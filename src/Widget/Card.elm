module Widget.Card exposing (link, linkWithImage, plain)

import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Pages
import Pages.ImagePath as ImagePath exposing (ImagePath)
import ViewSettings exposing (ViewSettings)


plain : ViewSettings -> List (Element.Attribute msg) -> Element msg -> Element msg
plain viewSettings attrs content =
    Element.el
        (commonAttributes viewSettings ++ attrs)
        content


link :
    ViewSettings
    -> List (Element.Attribute msg)
    ->
        { url : String
        , openInNewTab : Bool
        , content : Element msg
        }
    -> Element msg
link viewSettings attrs { url, openInNewTab, content } =
    linkRenderer openInNewTab
        []
        { url = url
        , label =
            Element.el
                (commonAttributes viewSettings ++ mouseOverAttributes viewSettings ++ attrs)
                content
        }


linkWithImage :
    ViewSettings
    -> List (Element.Attribute msg)
    ->
        { imagePath : ImagePath Pages.PathKey
        , imageDescription : String
        , url : String
        , openInNewTab : Bool
        , content : Element msg
        }
    -> Element msg
linkWithImage viewSettings attrs { url, imagePath, openInNewTab, imageDescription, content } =
    linkRenderer openInNewTab
        []
        { url = url
        , label =
            Element.column
                (commonAttributes viewSettings ++ mouseOverAttributes viewSettings ++ attrs)
                [ Element.image [ Element.width Element.fill ]
                    { src = ImagePath.toString imagePath
                    , description = imageDescription
                    }
                , content
                ]
        }


linkRenderer : Bool -> List (Element.Attribute msg) -> { url : String, label : Element msg } -> Element msg
linkRenderer openInNewTab =
    if openInNewTab then
        Element.newTabLink

    else
        Element.link


commonAttributes : ViewSettings -> List (Element.Attribute msg)
commonAttributes viewSettings =
    [ Background.color viewSettings.color.contentBackground
    , Border.shadow
        { offset = ( 0, 3 )
        , size = 0
        , blur = 6
        , color = viewSettings.color.shadow
        }
    ]


mouseOverAttributes : ViewSettings -> List (Element.Attribute msg)
mouseOverAttributes viewSettings =
    [ Element.mouseOver
        [ Element.moveUp 2
        , Border.shadow
            { offset = ( 0, 5 )
            , size = 0
            , blur = 6
            , color = viewSettings.color.shadow
            }
        ]
    ]
