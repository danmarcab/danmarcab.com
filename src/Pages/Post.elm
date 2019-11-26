module Pages.Post exposing (view)

import Date
import Element exposing (Element)
import Element.Border as Border
import Element.Font as Font
import Element.Region
import Html
import Html.Attributes
import Json.Encode
import Layout
import Metadata exposing (Metadata, PostMetadata)
import Pages
import Pages.PagePath exposing (PagePath)
import Pages.Platform exposing (Page)
import ViewSettings exposing (ViewSettings)
import Widget.Card as Card


view :
    { viewSettings : ViewSettings
    , siteMetadata : List ( PagePath Pages.PathKey, Metadata )
    , page : Page PostMetadata (Element msg) Pages.PathKey
    }
    -> Element msg
view { viewSettings, siteMetadata, page } =
    Layout.withSidebar
        { viewSettings = viewSettings
        , siteMetadata = siteMetadata
        , currentPath = page.path
        , content =
            Card.plain viewSettings
                [ Element.width Element.fill
                , Element.scrollbarY
                ]
            <|
                Element.column
                    [ Element.spacing viewSettings.spacing.lg
                    , Element.centerX
                    , Element.padding viewSettings.spacing.lg
                    , Element.width Element.fill
                    ]
                    [ postTitleView viewSettings page.metadata
                    , page.view
                    , Element.el
                        [ Element.width Element.fill
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
                      <|
                        Element.html <|
                            Html.node "simple-comments"
                                [ Html.Attributes.property "discussionId"
                                    (Json.Encode.string <| Pages.PagePath.toString page.path)
                                ]
                                []
                    ]
        }


postTitleView : ViewSettings -> PostMetadata -> Element msg
postTitleView viewSettings { title, published } =
    Element.column
        [ Element.width Element.fill
        , Element.spacing viewSettings.spacing.xs
        , Border.widthEach
            { top = 0
            , right = 0
            , bottom = 5
            , left = 0
            }
        , Element.paddingEach
            { top = viewSettings.spacing.sm
            , right = 0
            , bottom = viewSettings.spacing.sm
            , left = 0
            }
        ]
        [ Element.paragraph
            [ Font.bold
            , Element.Region.heading 1
            , Font.size viewSettings.font.size.xl
            ]
            [ Element.text title ]
        , Element.el
            [ Font.size viewSettings.font.size.xs
            , Font.color viewSettings.font.color.secondary
            ]
          <|
            Element.text (Date.format "dd MMM yyyy" published)
        ]
