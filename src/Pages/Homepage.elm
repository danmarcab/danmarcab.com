module Pages.Homepage exposing (view)

import Element exposing (Element)
import Layout
import Metadata exposing (HomepageMetadata, Metadata)
import Pages
import Pages.PagePath exposing (PagePath)
import Pages.Platform exposing (Page)
import ViewSettings exposing (ViewSettings)
import Widget.EmailList as EmailList
import Widget.LatestPosts as LatestPosts
import Widget.LatestProjects as LatestProjects


type alias MsgConfig msg =
    { onEmailUpdate : String -> msg }


view :
    { viewSettings : ViewSettings
    , emailList : EmailList.Model msg
    , siteMetadata : List ( PagePath Pages.PathKey, Metadata )
    }
    -> Element msg
view { viewSettings, emailList, siteMetadata } =
    Layout.withHeaderAndTwoColumns
        { viewSettings = viewSettings
        , emailList = emailList
        , leftColumn =
            LatestPosts.expanded viewSettings
                { siteMetadata = siteMetadata, postsToShow = 5 }
        , rightColumn =
            LatestProjects.view viewSettings
                { siteMetadata = siteMetadata, projectsToShow = 5 }
        }
