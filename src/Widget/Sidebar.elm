module Widget.Sidebar exposing (view)

import Element exposing (Element)
import Element.Font as Font
import Metadata exposing (Metadata(..))
import Pages
import Pages.ImagePath as ImagePath
import Pages.PagePath exposing (PagePath)
import ViewSettings exposing (ViewSettings)
import Widget.EmailList as EmailList
import Widget.LatestPosts as LatestPosts
import Widget.Sitename as Sitename


view : ViewSettings -> List ( PagePath Pages.PathKey, Metadata ) -> PagePath Pages.PathKey -> Element msg
view viewSettings siteMetadata _ =
    Element.column
        [ Element.height Element.fill
        , Element.width Element.fill
        , Element.alignTop
        , Element.spacing viewSettings.spacing.md
        ]
        [ Sitename.view viewSettings

        --            , currentlyReading
        --            , related (tags?)
        --            , posts in the same series
        , LatestPosts.compact viewSettings { postsToShow = 3, siteMetadata = siteMetadata }
        , EmailList.view viewSettings

        --        , followTwitter
        --        , github
        , Element.row [ Element.spacing viewSettings.spacing.xl ]
            []
        , Element.el [ Font.size viewSettings.font.size.sm ] <| Element.text "© 2019 - present Daniel Marin Cabillas"
        ]
