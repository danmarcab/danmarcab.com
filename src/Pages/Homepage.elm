module Pages.Homepage exposing (view)

import Element exposing (Element)
import Layout
import Metadata exposing (HomepageMetadata, Metadata)
import Pages
import Pages.PagePath exposing (PagePath)
import Pages.Platform exposing (Page)
import ViewSettings exposing (ViewSettings)
import Widget.LatestPosts as LatestPosts
import Widget.LatestProjects as LatestProjects


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
