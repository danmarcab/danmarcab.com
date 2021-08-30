module Page.Index exposing (Data, Model, Msg, page)

import Browser.Dom exposing (Element)
import Data.Post as Post
import Data.Project as Project
import DataSource exposing (DataSource)
import DataSource.File
import DataSource.Glob as Glob
import Date exposing (Date)
import Element exposing (Element)
import Head
import Head.Seo as Seo
import Html
import Layout
import OptimizedDecoder exposing (Decoder)
import OptimizedDecoder.Pipeline as OptimizedDecoder
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Path
import Shared
import View exposing (View)
import ViewSettings exposing (ViewSettings)
import Widget.LatestPosts as LatestPosts
import Widget.LatestProjects as LatestProjects


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    {}


page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }


data : DataSource Data
data =
    DataSource.map2 (\posts projects -> { posts = posts, projects = projects })
        Post.postsDataSource
        Project.projectsDataSource


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "danmarcab.com"
        , image =
            { url = Pages.Url.fromPath (Path.join [ "images", "icon.svg" ])
            , alt = "danmarcab.com logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "A blog where I write about computer science, generative art and other random stuff"
        , locale = Nothing
        , title = "danmarcab.com"
        }
        |> Seo.website


type alias Data =
    { posts : List Post.Metadata, projects : List Project.Metadata }


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl { viewSettings } static =
    { title = "danmarcab.com"
    , body =
        case viewSettings.size of
            ViewSettings.Small ->
                Layout.withHeader
                    { viewSettings = viewSettings
                    , content =
                        Element.column [ Element.spacing viewSettings.spacing.lg ]
                            [ LatestPosts.expanded viewSettings
                                { posts = static.data.posts, postsToShow = 5 }
                            , LatestProjects.view viewSettings
                                { projects = static.data.projects, projectsToShow = 5 }
                            ]
                    }

            _ ->
                Layout.withHeaderAndTwoColumns
                    { viewSettings = viewSettings
                    , leftColumn =
                        LatestPosts.expanded viewSettings
                            { posts = static.data.posts, postsToShow = 5 }
                    , rightColumn =
                        LatestProjects.view viewSettings
                            { projects = static.data.projects, projectsToShow = 5 }
                    }
    , fillHeight = False
    }
