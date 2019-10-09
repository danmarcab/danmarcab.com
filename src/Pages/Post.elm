module Pages.Post exposing (view)

import Date
import Element exposing (Element)
import Element.Font as Font
import Element.Region
import Layout
import Metadata exposing (Metadata, PostMetadata)
import Pages
import Pages.PagePath exposing (PagePath)
import Pages.Platform exposing (Page)
import ViewSettings exposing (ViewSettings)
import Widget.Card as Card


view :
    ViewSettings
    -> List ( PagePath Pages.PathKey, Metadata )
    -> Page PostMetadata (Element msg) Pages.PathKey
    -> Element msg
view viewSettings siteMetadata page =
    Layout.withSidebar viewSettings siteMetadata page.path <|
        Card.plain viewSettings <|
            Element.column
                [ Element.spacing viewSettings.spacing.md
                , Element.centerX
                , Element.padding viewSettings.spacing.lg
                ]
                [ postTitleView viewSettings page.metadata
                , page.view
                ]


postTitleView : ViewSettings -> PostMetadata -> Element msg
postTitleView viewSettings { title, published } =
    Element.column [ Element.spacing viewSettings.spacing.xs ]
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
