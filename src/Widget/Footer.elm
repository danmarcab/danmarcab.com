module Widget.Footer exposing (copyrightView, mailingListView, profilesView, view)

import Element exposing (Element)
import Element.Border as Border
import Element.Font as Font
import FeatherIcons as Icon
import ViewSettings exposing (ViewSettings)
import Widget.Icon as Icon


view : { viewSettings : ViewSettings } -> Element msg
view { viewSettings } =
    Element.wrappedRow
        [ Element.width Element.fill
        , Element.spacingXY viewSettings.spacing.xl viewSettings.spacing.md
        , Element.spaceEvenly
        , Element.alignBottom
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
        [ mailingListView viewSettings
        , profilesView viewSettings
        , copyrightView viewSettings
        ]


mailingListView : ViewSettings -> Element msg
mailingListView viewSettings =
    Element.row [ Font.size viewSettings.font.size.sm, Element.spacing viewSettings.spacing.md ]
        [ Element.text "Subscribe to my mailing list:", mailListLink viewSettings ]


profilesView : ViewSettings -> Element msg
profilesView viewSettings =
    Element.row [ Font.size viewSettings.font.size.sm, Element.spacing viewSettings.spacing.md ]
        [ Element.text "Find me on:"
        , emailLink viewSettings
        , twitterLink viewSettings
        , githubLink viewSettings
        , linkedinLink viewSettings
        ]


mailListLink : ViewSettings -> Element msg
mailListLink viewSettings =
    Element.newTabLink []
        { url = "https://mailchi.mp/145ed6fd7df3/danmarcab"
        , label =
            Icon.view
                { size = viewSettings.font.size.lg
                , color = viewSettings.font.color.primary
                }
                Icon.mail
        }


twitterLink : ViewSettings -> Element msg
twitterLink viewSettings =
    Element.newTabLink []
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
    Element.newTabLink []
        { url = "https://github.com/danmarcab"
        , label =
            Icon.view
                { size = viewSettings.font.size.lg
                , color = viewSettings.font.color.primary
                }
                Icon.github
        }


emailLink : ViewSettings -> Element msg
emailLink viewSettings =
    Element.newTabLink []
        { url = "mailto:danmarcab+web@gmail.com"
        , label =
            Icon.view
                { size = viewSettings.font.size.lg
                , color = viewSettings.font.color.primary
                }
                Icon.mail
        }


linkedinLink : ViewSettings -> Element msg
linkedinLink viewSettings =
    Element.newTabLink []
        { url = "https://www.linkedin.com/in/daniel-mar%C3%ADn-cabillas-09b50254/"
        , label =
            Icon.view
                { size = viewSettings.font.size.lg
                , color = viewSettings.font.color.primary
                }
                Icon.linkedin
        }


copyrightView : ViewSettings -> Element msg
copyrightView viewSettings =
    Element.el [ Font.size viewSettings.font.size.sm ] <|
        Element.text "© 2019 - present Daniel Marin Cabillas"
