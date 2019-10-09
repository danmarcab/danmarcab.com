module Widget.Card exposing (link, linkWithImage, plain)

import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Pages
import Pages.ImagePath as ImagePath exposing (ImagePath)
import ViewSettings exposing (ViewSettings)


plain : ViewSettings -> Element msg -> Element msg
plain viewSettings content =
    Element.el
        (commonAttributes viewSettings)
        content


link :
    ViewSettings
    ->
        { url : String
        , openInNewTab : Bool
        , content : Element msg
        }
    -> Element msg
link viewSettings { url, openInNewTab, content } =
    linkRenderer openInNewTab
        []
        { url = url
        , label =
            Element.el
                (commonAttributes viewSettings ++ mouseOverAttributes viewSettings)
                content
        }


linkWithImage :
    ViewSettings
    ->
        { imagePath : ImagePath Pages.PathKey
        , imageDescription : String
        , url : String
        , openInNewTab : Bool
        , content : Element msg
        }
    -> Element msg
linkWithImage viewSettings { url, imagePath, openInNewTab, imageDescription, content } =
    linkRenderer openInNewTab
        []
        { url = url
        , label =
            Element.column
                (commonAttributes viewSettings ++ mouseOverAttributes viewSettings)
                [ Element.image [ Element.width Element.fill ]
                    { src = ImagePath.toString imagePath
                    , description = imageDescription
                    }
                , content
                ]
        }


linkRenderer openInNewTab =
    if openInNewTab then
        Element.newTabLink

    else
        Element.link


commonAttributes : ViewSettings -> List (Element.Attr () msg)
commonAttributes viewSettings =
    [ Background.color viewSettings.color.contentBackground
    , Border.shadow
        { offset = ( 0, 3 )
        , size = 0
        , blur = 6
        , color = viewSettings.color.shadow
        }
    ]


mouseOverAttributes : ViewSettings -> List (Element.Attr () msg)
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
