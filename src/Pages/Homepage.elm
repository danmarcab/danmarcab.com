module Pages.Homepage exposing (view)

import Date
import Element exposing (Element)
import Element.Border
import Element.Font
import Layout
import Metadata exposing (HomepageMetadata, Metadata)
import Pages
import Pages.PagePath as PagePath exposing (PagePath)
import Pages.Platform exposing (Page)
import ViewSettings exposing (ViewSettings)
import Widget.EmailList
import Widget.LatestPosts as LatestPosts
import Widget.LatestProjects as LatestProjects
import Widget.Sitename as Sitename


view :
    ViewSettings
    -> List ( PagePath Pages.PathKey, Metadata )
    -> Page HomepageMetadata (Element msg) Pages.PathKey
    -> Element msg
view viewSettings siteMetadata page =
    Layout.withHeaderAndTwoColumns
        viewSettings
        { description = page.metadata.description
        , leftColumn =
            LatestPosts.expanded viewSettings
                { siteMetadata = siteMetadata, postsToShow = 5 }
        , rightColumn =
            LatestProjects.view viewSettings
                { siteMetadata = siteMetadata, projectsToShow = 5 }
        }


introView :
    ViewSettings
    -> Page HomepageMetadata (Element msg) Pages.PathKey
    -> Element msg
introView viewSettings page =
    Element.row
        [ Element.width Element.fill
        , Element.spaceEvenly
        ]
        [ Element.column [ Element.spacing viewSettings.spacing.md ]
            [ Sitename.view viewSettings
            , Element.text page.metadata.description
            ]
        , Widget.EmailList.view viewSettings
        ]
