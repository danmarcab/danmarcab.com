module Layout exposing (withHeader, withHeaderAndTwoColumns, withSidebar)

import Element exposing (Element)
import Element.Region
import Metadata exposing (Metadata)
import Pages
import Pages.PagePath exposing (PagePath)
import ViewSettings exposing (ViewSettings)
import Widget.EmailList as EmailList
import Widget.Footer as Footer
import Widget.Header as Header
import Widget.Sidebar as Sidebar


type alias MsgConfig msg =
    { onEmailUpdate : String -> msg }


withSidebar :
    { viewSettings : ViewSettings
    , emailList : EmailList.Model msg
    , siteMetadata : List ( PagePath Pages.PathKey, Metadata )
    , currentPath : PagePath Pages.PathKey
    , content : Element msg
    }
    -> Element msg
withSidebar { viewSettings, emailList, siteMetadata, currentPath, content } =
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
            content
        , Element.el
            [ Element.width (Element.fillPortion 1)
            , Element.height Element.fill
            , Element.Region.navigation
            ]
            (Sidebar.view
                { viewSettings = viewSettings
                , emailList = emailList
                , siteMetadata = siteMetadata
                , currentPath = currentPath
                }
            )
        ]


withHeaderAndTwoColumns :
    { viewSettings : ViewSettings
    , emailList : EmailList.Model msg
    , leftColumn : Element msg
    , rightColumn : Element msg
    }
    -> Element msg
withHeaderAndTwoColumns { viewSettings, emailList, leftColumn, rightColumn } =
    Element.column
        [ Element.width (Element.fill |> Element.maximum 1400)
        , Element.height Element.fill
        , Element.padding viewSettings.spacing.lg
        , Element.spacing viewSettings.spacing.lg
        , Element.centerX
        , Element.Region.mainContent
        ]
        [ Header.view { viewSettings = viewSettings, emailList = emailList }
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
        , Footer.view { viewSettings = viewSettings, emailList = emailList }
        ]


withHeader :
    { viewSettings : ViewSettings, emailList : EmailList.Model msg, content : Element msg }
    -> Element msg
withHeader { viewSettings, emailList, content } =
    Element.column
        [ Element.width (Element.fill |> Element.maximum 1400)
        , Element.height Element.fill
        , Element.padding viewSettings.spacing.lg
        , Element.spacing viewSettings.spacing.xl
        , Element.centerX
        , Element.Region.mainContent
        ]
        [ Header.view { viewSettings = viewSettings, emailList = emailList }
        , content
        , Footer.view { viewSettings = viewSettings, emailList = emailList }
        ]
