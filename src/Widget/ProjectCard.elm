module Widget.ProjectCard exposing (view)

import Data.Project as Project
import Date
import Element exposing (Element)
import Element.Font as Font
import FeatherIcons as Icon
import Pages
import ViewSettings exposing (ViewSettings)
import Widget.Card as Card
import Widget.Icon as Icon


view : ViewSettings -> { project : Project.Metadata } -> Element msg
view viewSettings { project } =
    let
        ( external, url ) =
            case project.externalUrl of
                Just externalUrl ->
                    ( True, externalUrl )

                Nothing ->
                    ( False, "/projects/" ++ project.slug )
    in
    Card.linkWithImage viewSettings
        []
        { url = url
        , openInNewTab = external
        , imagePath = project.image
        , imageDescription = project.title
        , content =
            Element.el [ Element.padding viewSettings.spacing.md ] <|
                projectView viewSettings project
        }


projectView : ViewSettings -> Project.Metadata -> Element msg
projectView viewSettings projectMetadata =
    Element.column
        [ Element.spacing viewSettings.spacing.sm
        ]
        [ Element.row
            [ Element.width Element.fill
            , Element.spacing viewSettings.spacing.sm
            ]
            [ Element.paragraph
                [ Font.size viewSettings.font.size.lg
                , Font.bold
                ]
                [ Element.text projectMetadata.title
                ]
            , case projectMetadata.githubUrl of
                Just url ->
                    Element.newTabLink []
                        { url = url
                        , label =
                            Icon.view
                                { size = viewSettings.font.size.lg
                                , color = viewSettings.font.color.primary
                                }
                                Icon.github
                        }

                Nothing ->
                    Element.none
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
