module Layout exposing (withHeader, withHeaderAndTwoColumns, withSidebar)

import Element exposing (Element)
import Element.Region
import Metadata exposing (Metadata)
import Pages
import Pages.PagePath exposing (PagePath)
import ViewSettings exposing (ViewSettings)
import Widget.Header as Header
import Widget.Sidebar as Sidebar


withSidebar : ViewSettings -> List ( PagePath Pages.PathKey, Metadata ) -> PagePath Pages.PathKey -> Element msg -> Element msg
withSidebar viewSettings pagesInfo currentPagePath contentView =
    Element.row
        [ Element.width (Element.fill |> Element.maximum 1400)
        , Element.height Element.fill
        , Element.padding viewSettings.spacing.lg
        , Element.spacing viewSettings.spacing.xl
        , Element.centerX
        ]
        [ Element.el
            [ Element.height Element.fill
            , Element.Region.mainContent
            , Element.width (Element.fillPortion 3)
            ]
            contentView
        , Element.el
            [ Element.width (Element.fillPortion 1)
            , Element.height Element.fill
            , Element.Region.navigation
            ]
            (Sidebar.view viewSettings pagesInfo currentPagePath)
        ]


withHeaderAndTwoColumns :
    ViewSettings
    ->
        { description : String
        , leftColumn : Element msg
        , rightColumn : Element msg
        }
    -> Element msg
withHeaderAndTwoColumns viewSettings { description, leftColumn, rightColumn } =
    Element.column
        [ Element.width (Element.fill |> Element.maximum 1400)
        , Element.height Element.fill
        , Element.padding viewSettings.spacing.lg
        , Element.spacing viewSettings.spacing.lg
        , Element.centerX
        , Element.Region.mainContent
        ]
        [ Header.view viewSettings { description = description }
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
        ]


withHeader :
    ViewSettings
    -> { content : Element msg }
    -> Element msg
withHeader viewSettings { content } =
    Element.column
        [ Element.width (Element.fill |> Element.maximum 1400)
        , Element.height Element.fill
        , Element.padding viewSettings.spacing.lg
        , Element.spacing viewSettings.spacing.xl
        , Element.centerX
        , Element.Region.mainContent
        ]
        [ Header.view viewSettings { description = "A blog where I write about computer science, generative art and other random stuff" }
        , content
        ]
