module Widget.LatestProjects exposing (view)

import Date
import Element exposing (Element)
import Element.Border as Border
import Element.Font as Font
import Metadata exposing (Metadata(..), ProjectMetadata)
import Pages
import Pages.PagePath exposing (PagePath)
import ViewSettings exposing (ViewSettings)
import Widget.ProjectCard as ProjectCard


view :
    ViewSettings
    ->
        { projectsToShow : Int
        , siteMetadata : List ( PagePath Pages.PathKey, Metadata )
        }
    -> Element msg
view viewSettings opts =
    let
        latestProjects =
            takeProjects opts
    in
    Element.column
        [ Element.spacing viewSettings.spacing.md
        , Element.width Element.fill
        ]
        [ listHeading viewSettings
        , Element.column [ Element.spacing viewSettings.spacing.lg ]
            (List.map
                (\( path, project ) ->
                    ProjectCard.view viewSettings { path = path, project = project }
                )
                latestProjects
            )
        ]


takeProjects :
    { projectsToShow : Int
    , siteMetadata : List ( PagePath Pages.PathKey, Metadata )
    }
    -> List ( PagePath Pages.PathKey, ProjectMetadata )
takeProjects { projectsToShow, siteMetadata } =
    List.filterMap
        (\( path, metadata ) ->
            case metadata of
                Metadata.Project meta ->
                    if meta.draft then
                        Nothing

                    else
                        Just ( path, meta )

                _ ->
                    Nothing
        )
        siteMetadata
        |> List.sortBy (\( _, { published } ) -> Date.toRataDie published)
        |> List.take projectsToShow
        --        REMOVE
        |> List.repeat projectsToShow
        |> List.concat


listHeading : ViewSettings -> Element msg
listHeading viewSettings =
    Element.el
        [ Font.size viewSettings.font.size.lg
        , Font.color viewSettings.font.color.secondary
        , Element.width Element.fill
        , Font.variant Font.smallCaps
        , Element.paddingEach
            { bottom = viewSettings.spacing.xs
            , top = 0
            , left = 0
            , right = 0
            }
        , Border.widthEach
            { bottom = 1
            , top = 0
            , left = 0
            , right = 0
            }
        , Border.color viewSettings.font.color.secondary
        ]
    <|
        Element.text "latest projects"
