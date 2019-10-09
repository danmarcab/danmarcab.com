module Pages.Project exposing (view)

import Element exposing (Element)
import Layout
import Metadata exposing (Metadata, ProjectMetadata)
import Pages
import Pages.PagePath exposing (PagePath)
import Pages.Platform exposing (Page)
import ViewSettings exposing (ViewSettings)
import Widget.ProjectCard as ProjectCard


view :
    ViewSettings
    -> List ( PagePath Pages.PathKey, Metadata )
    -> Page ProjectMetadata (Element msg) Pages.PathKey
    -> Element msg
view viewSettings _ page =
    case page.metadata.externalUrl of
        Just _ ->
            viewExternalProject viewSettings page

        Nothing ->
            Element.text "TODO"


viewExternalProject :
    ViewSettings
    -> Page ProjectMetadata (Element msg) Pages.PathKey
    -> Element msg
viewExternalProject viewSettings page =
    Layout.withHeader viewSettings
        { content =
            Element.column
                [ Element.width (Element.fill |> Element.maximum 500)
                , Element.centerX
                , Element.spacing viewSettings.spacing.md
                ]
                [ Element.paragraph [] [ Element.text "The project you are viewing is hosted in a external page, please click on the project card to open it in a new tab." ]
                , ProjectCard.view viewSettings { path = page.path, project = page.metadata }
                ]
        }
