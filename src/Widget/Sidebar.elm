module Widget.Sidebar exposing (view)

import Element exposing (Element)
import Element.Border as Border
import Element.Font as Font
import FeatherIcons as Icon
import Metadata exposing (Metadata(..))
import Pages
import Pages.ImagePath as ImagePath
import Pages.PagePath exposing (PagePath)
import ViewSettings exposing (ViewSettings)
import Widget.EmailList as EmailList
import Widget.Footer as Footer
import Widget.LatestPosts as LatestPosts
import Widget.Sitename as Sitename


view :
    { viewSettings : ViewSettings
    , emailList : EmailList.Model msg
    , siteMetadata : List ( PagePath Pages.PathKey, Metadata )
    , currentPath : PagePath Pages.PathKey
    }
    -> Element msg
view { viewSettings, emailList, siteMetadata } =
    Element.column
        [ Element.height Element.fill
        , Element.width Element.fill
        , Element.alignTop
        , Element.spacing viewSettings.spacing.md
        ]
        [ Element.el
            [ Element.width Element.fill
            , Border.widthEach
                { top = 0
                , right = 0
                , bottom = 5
                , left = 0
                }
            , Element.paddingEach
                { top = 0
                , right = 0
                , bottom = viewSettings.spacing.sm
                , left = 0
                }
            ]
          <|
            Sitename.view viewSettings

        --            , currentlyReading
        --            , related (tags?)
        --            , posts in the same series
        , LatestPosts.compact viewSettings { postsToShow = 3, siteMetadata = siteMetadata }
        , Element.column
            [ Element.alignBottom
            , Element.spacing viewSettings.spacing.sm
            , Element.width Element.fill
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
            [ EmailList.view viewSettings emailList
            , Footer.profilesView viewSettings
            , Footer.copyrightView viewSettings
            ]
        ]
