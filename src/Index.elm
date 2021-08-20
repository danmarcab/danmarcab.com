module Page.Index exposing (Data, Model, Msg, page)

import Browser.Dom exposing (Element)
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
    DataSource.map (\postsInfo -> { posts = postsInfo }) postsData


postsData : DataSource (List PostInfo)
postsData =
    Glob.succeed
        (\filePath slug ->
            { filePath = filePath
            , slug = slug
            }
        )
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "old/content/posts/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toDataSource
        |> DataSource.map
            (\posts ->
                List.map
                    (\blogPost ->
                        DataSource.File.onlyFrontmatter postInfoDecoder blogPost.filePath
                    )
                    posts
            )
        |> DataSource.resolve


type alias PostInfo =
    { title : String
    , description : String
    , published : Date
    , image : String
    , draft : Bool
    }


postInfoDecoder : Decoder PostInfo
postInfoDecoder =
    OptimizedDecoder.decode PostInfo
        |> OptimizedDecoder.required "title" OptimizedDecoder.string
        |> OptimizedDecoder.required "description" OptimizedDecoder.string
        |> OptimizedDecoder.required "published" dateDecoder
        |> OptimizedDecoder.required "image" OptimizedDecoder.string
        |> OptimizedDecoder.optional "draft" OptimizedDecoder.bool False


dateDecoder : Decoder Date
dateDecoder =
    OptimizedDecoder.string
        |> OptimizedDecoder.andThen
            (\isoString ->
                case Date.fromIsoString isoString of
                    Ok date ->
                        OptimizedDecoder.succeed date

                    Err error ->
                        OptimizedDecoder.fail error
            )


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing
        , title = "TODO title" -- metadata.title -- TODO
        }
        |> Seo.website


type alias Data =
    { posts : List PostInfo }


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl { viewSettings } static =
    { title = "Hello"
    , body =
        case viewSettings.size of
            ViewSettings.Small ->
                Layout.withHeader
                    { viewSettings = viewSettings
                    , content =
                        Element.column [ Element.spacing viewSettings.spacing.lg ]
                            [ LatestPosts.expanded viewSettings
                                { siteMetadata = siteMetadata, postsToShow = 5 }
                            , LatestProjects.view viewSettings
                                { siteMetadata = siteMetadata, projectsToShow = 5 }
                            ]
                    }

            _ ->
                Layout.withHeaderAndTwoColumns
                    { viewSettings = viewSettings
                    , leftColumn =
                        LatestPosts.expanded viewSettings
                            { siteMetadata = siteMetadata, postsToShow = 5 }
                    , rightColumn =
                        LatestProjects.view viewSettings
                            { siteMetadata = siteMetadata, projectsToShow = 5 }
                    }
    , fillHeight = False
    }
