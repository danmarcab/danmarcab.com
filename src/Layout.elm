module Layout exposing (fullScreen, withHeader, withHeaderAndTwoColumns, withSidebar)

import Data.Post as Post
import Element exposing (Element)
import Element.Background as Background
import Element.Region
import Pages
import ViewSettings exposing (ViewSettings)
import Widget.Footer as Footer
import Widget.Header as Header
import Widget.MinimalHeader as MinimalHeader
import Widget.Sidebar as Sidebar


withSidebar :
    { viewSettings : ViewSettings
    , currentPath : String
    , posts : List Post.Metadata
    , content : Element msg
    }
    -> Element msg
withSidebar { viewSettings, currentPath, posts, content } =
    let
        padding =
            viewSettings.spacing.lg

        spacing =
            viewSettings.spacing.xl

        widthWithoutPaddingAndSpacing =
            min viewSettings.pixelSize.width 1400 - 2 * padding - spacing

        portionWidth =
            widthWithoutPaddingAndSpacing // 4

        sidebarWidth =
            portionWidth

        contentWidth =
            3 * portionWidth
    in
    Element.row
        [ Element.width (Element.fill |> Element.maximum 1400)
        , Element.height Element.fill
        , Element.padding padding
        , Element.spacing spacing
        , Element.centerX
        ]
        [ Element.el
            [ Element.width (Element.px sidebarWidth)
            , Element.height Element.fill
            , Element.Region.navigation
            ]
            (Sidebar.view
                { viewSettings = viewSettings
                , posts = posts
                , currentPath = currentPath
                }
            )
        , Element.el
            [ Element.height Element.fill
            , Element.Region.mainContent
            , Element.width (Element.px contentWidth)
            ]
            content
        ]


withHeaderAndTwoColumns :
    { viewSettings : ViewSettings
    , leftColumn : Element msg
    , rightColumn : Element msg
    }
    -> Element msg
withHeaderAndTwoColumns { viewSettings, leftColumn, rightColumn } =
    Element.column
        [ Element.width (Element.fill |> Element.maximum 1400)
        , Element.height Element.fill
        , Element.padding viewSettings.spacing.lg
        , Element.spacing viewSettings.spacing.lg
        , Element.centerX
        , Background.color viewSettings.color.mainBackground
        , Element.Region.mainContent
        ]
        [ Header.view { viewSettings = viewSettings }
        , Element.row
            [ Element.width Element.fill
            , Element.height Element.fill
            , Element.spacing viewSettings.spacing.xl
            ]
            [ Element.el
                [ Element.height Element.fill
                , Element.width (Element.fillPortion 1)
                ]
                leftColumn
            , Element.el
                [ Element.width (Element.fillPortion 1)
                , Element.height Element.fill
                ]
                rightColumn
            ]
        , Footer.view { viewSettings = viewSettings }
        ]


withHeader :
    { viewSettings : ViewSettings, content : Element msg }
    -> Element msg
withHeader { viewSettings, content } =
    Element.column
        [ Element.width (Element.fill |> Element.maximum 1400)
        , Element.height Element.fill
        , Element.padding viewSettings.spacing.lg
        , Element.spacing viewSettings.spacing.lg
        , Element.centerX
        , Element.Region.mainContent
        ]
        [ Header.view { viewSettings = viewSettings }
        , content
        , Footer.view { viewSettings = viewSettings }
        ]


fullScreen :
    { viewSettings : ViewSettings, content : Element msg }
    -> Element msg
fullScreen { viewSettings, content } =
    Element.el
        [ Element.Region.mainContent
        , Element.inFront <| MinimalHeader.view { viewSettings = viewSettings }
        ]
    <|
        content
