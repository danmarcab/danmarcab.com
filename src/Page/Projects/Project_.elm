module Page.Projects.Project_ exposing (Data, Model, Msg, RouteParams, data, head, page, routes, view)

import Data.Project as Project
import DataSource exposing (DataSource)
import Date
import Element exposing (Element)
import Element.Border as Border
import Element.Font as Font
import Element.Keyed
import Element.Region
import Head
import Head.Seo as Seo
import Html
import Html.Attributes
import Json.Encode
import Layout
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Path
import Shared
import View exposing (View)
import ViewSettings exposing (ViewSettings)
import Widget.ProjectCard as ProjectCard


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    { project : String }


page : Page RouteParams Data
page =
    Page.prerender
        { head = head
        , routes = routes
        , data = data
        }
        |> Page.buildNoState { view = view }


routes : DataSource (List RouteParams)
routes =
    Project.projectsDataSource
        |> DataSource.map (\projects -> List.map (\project -> { project = project.slug }) projects)


data : RouteParams -> DataSource Data
data routeParams =
    DataSource.map Data
        (Project.metadataDataSource routeParams.project)


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    let
        metadata =
            static.data.metadata
    in
    Seo.summaryLarge
        { canonicalUrlOverride = Nothing
        , siteName = "danmarcab.com"
        , image =
            { url = Pages.Url.fromPath (Path.fromString metadata.image)
            , alt = metadata.description
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = metadata.description
        , locale = Nothing
        , title = metadata.title
        }
        |> Seo.website


type alias Data =
    { metadata : Project.Metadata
    }


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = static.data.metadata.title
    , body =
        case static.data.metadata.externalUrl of
            Just _ ->
                viewExternalProject
                    { viewSettings = sharedModel.viewSettings
                    , project = static.data.metadata
                    }

            Nothing ->
                Layout.fullScreen
                    { viewSettings = sharedModel.viewSettings
                    , content = renderProject sharedModel.viewSettings static.data.metadata
                    }
    , fillHeight = True
    }


viewExternalProject :
    { viewSettings : ViewSettings
    , project : Project.Metadata
    }
    -> Element msg
viewExternalProject { viewSettings, project } =
    Layout.withHeader
        { viewSettings = viewSettings
        , content =
            Element.column
                [ Element.width (Element.fill |> Element.maximum 500)
                , Element.height Element.fill
                , Element.centerX
                , Element.spacing viewSettings.spacing.md
                ]
                [ Element.paragraph [] [ Element.text "The project you are viewing is hosted in a external page, please click on the project card to open it in a new tab." ]
                , ProjectCard.view viewSettings { project = project }
                ]
        }


renderProject : ViewSettings -> Project.Metadata -> Element Msg
renderProject viewSettings project =
    case project.slug of
        "quad-division" ->
            Element.html <|
                Html.node "elm-app"
                    [ Html.Attributes.property "src" (Json.Encode.string "https://quad-division.netlify.com/QuadDivision.js")
                    , Html.Attributes.property "appname" (Json.Encode.string "QuadDivision")
                    , Html.Attributes.property "flags" (Json.Encode.string "%7B%22elmUIEmbedded%22%3A%20true%7D")
                    ]
                    []

        _ ->
            Element.text "TODO"
