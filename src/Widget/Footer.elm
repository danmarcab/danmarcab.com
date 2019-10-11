module Widget.Footer exposing (copyrightView, profilesView, view)

import Element exposing (Element)
import Element.Border as Border
import Element.Font as Font
import FeatherIcons as Icon
import ViewSettings exposing (ViewSettings)
import Widget.EmailList as EmailList
import Widget.Icon as Icon


view : { viewSettings : ViewSettings, emailList : EmailList.Model msg } -> Element msg
view { viewSettings, emailList } =
    Element.row
        [ Element.width Element.fill
        , Element.spaceEvenly
        , Border.widthEach
            { top = 5
            , right = 0
            , bottom = 0
            , left = 0
            }
        , Element.paddingEach
            { top = viewSettings.spacing.sm
            , right = 0
            , bottom = 0
            , left = 0
            }
        ]
        [ Element.column
            [ Element.spacing viewSettings.spacing.sm
            , Element.width Element.fill
            , Element.paddingEach
                { top = 0
                , right = viewSettings.spacing.lg
                , bottom = 0
                , left = 0
                }
            ]
            [ profilesView viewSettings
            , copyrightView viewSettings
            ]
        , EmailList.view viewSettings emailList
        ]


profilesView : ViewSettings -> Element msg
profilesView viewSettings =
    Element.row [ Font.size viewSettings.font.size.sm, Element.spacing viewSettings.spacing.md ]
        [ Element.text "Find me on:", twitterLink viewSettings, githubLink viewSettings ]


twitterLink : ViewSettings -> Element msg
twitterLink viewSettings =
    Element.link []
        { url = "https://twitter.com/danmarcab"
        , label =
            Icon.view
                { size = viewSettings.font.size.lg
                , color = viewSettings.font.color.primary
                }
                Icon.twitter
        }


githubLink : ViewSettings -> Element msg
githubLink viewSettings =
    Element.link []
        { url = "https://github.com/danmarcab"
        , label =
            Icon.view
                { size = viewSettings.font.size.lg
                , color = viewSettings.font.color.primary
                }
                Icon.github
        }


copyrightView : ViewSettings -> Element msg
copyrightView viewSettings =
    Element.el [ Font.size viewSettings.font.size.sm ] <|
        Element.text "© 2019 - present Daniel Marin Cabillas"
