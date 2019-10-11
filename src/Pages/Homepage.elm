module Pages.Homepage exposing (view)

import Element exposing (Element)
import Layout
import Metadata exposing (Metadata)
import Pages
import Pages.PagePath exposing (PagePath)
import ViewSettings exposing (ViewSettings)
import Widget.LatestPosts as LatestPosts
import Widget.LatestProjects as LatestProjects


view :
    { viewSettings : ViewSettings
    , siteMetadata : List ( PagePath Pages.PathKey, Metadata )
    }
    -> Element msg
view { viewSettings, siteMetadata } =
    Layout.withHeaderAndTwoColumns
        { viewSettings = viewSettings
        , leftColumn =
            LatestPosts.expanded viewSettings
                { siteMetadata = siteMetadata, postsToShow = 5 }
        , rightColumn =
            LatestProjects.view viewSettings
                { siteMetadata = siteMetadata, projectsToShow = 5 }
        }
