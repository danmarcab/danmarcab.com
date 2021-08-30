module Widget.LatestProjects exposing (view)

import Data.Project as Project
import Date
import Element exposing (Element)
import Element.Border as Border
import Element.Font as Font
import Pages
import ViewSettings exposing (ViewSettings)
import Widget.ProjectCard as ProjectCard


view :
    ViewSettings
    ->
        { projectsToShow : Int
        , projects : List Project.Metadata
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
                (\project ->
                    ProjectCard.view viewSettings { project = project }
                )
                latestProjects
            )
        ]


takeProjects :
    { projectsToShow : Int
    , projects : List Project.Metadata
    }
    -> List Project.Metadata
takeProjects { projectsToShow, projects } =
    List.filterMap
        (\project ->
            if project.draft then
                Nothing

            else
                Just project
        )
        projects
        |> List.sortBy (\{ published } -> -(Date.toRataDie published))
        |> List.take projectsToShow


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
