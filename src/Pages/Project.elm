module Pages.Project exposing (view)

import Element exposing (Element)
import Layout
import Metadata exposing (Metadata, ProjectMetadata)
import Pages
import Pages.PagePath exposing (PagePath)
import Pages.Platform exposing (Page)
import ViewSettings exposing (ViewSettings)
import Widget.EmailList as EmailList
import Widget.ProjectCard as ProjectCard


type alias MsgConfig msg =
    { onEmailUpdate : String -> msg }


view :
    { viewSettings : ViewSettings
    , emailList : EmailList.Model msg
    , siteMetadata : List ( PagePath Pages.PathKey, Metadata )
    , page : Page ProjectMetadata (Element msg) Pages.PathKey
    }
    -> Element msg
view { viewSettings, emailList, page } =
    case page.metadata.externalUrl of
        Just _ ->
            viewExternalProject
                { viewSettings = viewSettings
                , emailList = emailList
                , page = page
                }

        Nothing ->
            Element.text "TODO"


viewExternalProject :
    { viewSettings : ViewSettings
    , emailList : EmailList.Model msg
    , page : Page ProjectMetadata (Element msg) Pages.PathKey
    }
    -> Element msg
viewExternalProject { viewSettings, emailList, page } =
    Layout.withHeader
        { viewSettings = viewSettings
        , emailList = emailList
        , content =
            Element.column
                [ Element.width (Element.fill |> Element.maximum 500)
                , Element.centerX
                , Element.spacing viewSettings.spacing.md
                ]
                [ Element.paragraph [] [ Element.text "The project you are viewing is hosted in a external page, please click on the project card to open it in a new tab." ]
                , ProjectCard.view viewSettings { path = page.path, project = page.metadata }
                ]
        }
