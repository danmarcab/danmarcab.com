module Widget.Sidebar exposing (view)

import Data.Post as Post
import Data.Project as Project
import Element exposing (Element)
import Element.Border as Border
import Pages
import ViewSettings exposing (ViewSettings)
import Widget.Footer as Footer
import Widget.LatestPosts as LatestPosts
import Widget.Sitename as Sitename


view :
    { viewSettings : ViewSettings
    , posts : List Post.Metadata
    , currentPath : String
    }
    -> Element msg
view { viewSettings, posts } =
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
        , LatestPosts.compact viewSettings { postsToShow = 3, posts = posts }
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
            [ Footer.mailingListView viewSettings
            , Footer.profilesView viewSettings
            , Footer.copyrightView viewSettings
            ]
        ]
