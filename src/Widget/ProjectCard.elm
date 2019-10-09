module Widget.ProjectCard exposing (..)

import Date
import Element exposing (Element)
import Element.Font as Font
import Metadata exposing (ProjectMetadata)
import Pages
import Pages.PagePath as PagePath exposing (PagePath)
import ViewSettings exposing (ViewSettings)
import Widget.Card as Card


view : ViewSettings -> { path : PagePath Pages.PathKey, project : ProjectMetadata } -> Element msg
view viewSettings { path, project } =
    let
        ( external, url ) =
            case project.externalUrl of
                Just externalUrl ->
                    ( True, externalUrl )

                Nothing ->
                    ( False, PagePath.toString path )
    in
    Card.linkWithImage viewSettings
        { url = url
        , openInNewTab = external
        , imagePath = project.image
        , imageDescription = project.title
        , content =
            Element.el [ Element.padding viewSettings.spacing.md ] <|
                projectView viewSettings project
        }


projectView : ViewSettings -> ProjectMetadata -> Element msg
projectView viewSettings projectMetadata =
    Element.column
        [ Element.spacing viewSettings.spacing.sm
        ]
        [ Element.paragraph
            [ Font.size viewSettings.font.size.lg
            , Font.bold
            ]
            [ Element.text projectMetadata.title
            ]
        , Element.el
            [ Font.size viewSettings.font.size.sm
            , Font.color viewSettings.font.color.secondary
            ]
          <|
            Element.text <|
                Date.format "dd MMM yyyy" projectMetadata.published
        , Element.paragraph
            [ Font.size viewSettings.font.size.md
            ]
            [ Element.text projectMetadata.description
            ]
        ]
