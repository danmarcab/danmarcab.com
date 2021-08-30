module Page.Posts.Post_ exposing (Data, Model, Msg, page)

import Data.Post as Post
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
import Widget.Card as Card


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    { post : String }


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
    Post.postsDataSource
        |> DataSource.map (\posts -> List.map (\post -> { post = post.slug }) posts)


data : RouteParams -> DataSource Data
data routeParams =
    DataSource.map3 Data
        (Post.contentDataSource routeParams.post)
        (Post.metadataDataSource routeParams.post)
        Post.postsDataSource


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
        |> Seo.article
            { tags = []
            , section = Nothing
            , publishedTime = Just (Date.toIsoString metadata.published)
            , modifiedTime = Nothing
            , expirationTime = Nothing
            }


type alias Data =
    { content : Post.Content Msg
    , metadata : Post.Metadata
    , posts : List Post.Metadata
    }


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = static.data.metadata.title
    , body =
        case sharedModel.viewSettings.size of
            ViewSettings.Large ->
                Layout.withSidebar
                    { viewSettings = sharedModel.viewSettings
                    , posts = static.data.posts
                    , currentPath = static.data.metadata.slug
                    , content = contentView sharedModel static []
                    }

            _ ->
                Layout.withHeader
                    { viewSettings = sharedModel.viewSettings
                    , content = contentView sharedModel static [ Element.height Element.fill ]
                    }
    , fillHeight = True
    }


contentView :
    Shared.Model
    -> StaticPayload Data RouteParams
    -> List (Element.Attribute msg)
    -> Element msg
contentView { viewSettings } static attrs =
    Card.plain viewSettings
        ([ Element.width Element.fill
         , Element.scrollbarY
         , Element.htmlAttribute <| Html.Attributes.id "post-content-container"
         ]
            ++ attrs
        )
    <|
        Element.column
            [ Element.spacing viewSettings.spacing.lg
            , Element.centerX
            , Element.padding viewSettings.spacing.lg
            , Element.width Element.fill
            ]
            [ postTitleView viewSettings static.data.metadata
            , Element.map never <| static.data.content viewSettings
            , Element.el
                [ Element.width Element.fill
                , Border.widthEach
                    { top = 5
                    , right = 0
                    , bottom = 0
                    , left = 0
                    }
                , Element.paddingEach
                    { top = viewSettings.spacing.sm
                    , right = 0
                    , bottom = 0
                    , left = 0
                    }
                ]
              <|
                Element.Keyed.el [ Element.width Element.fill ]
                    ( "/posts/" ++ static.data.metadata.slug
                    , Element.html <|
                        Html.node "simple-comments"
                            [ Html.Attributes.property "discussionId"
                                (Json.Encode.string <| "/posts/" ++ static.data.metadata.slug)
                            ]
                            []
                    )
            ]


postTitleView : ViewSettings -> Post.Metadata -> Element msg
postTitleView viewSettings { title, published } =
    Element.column
        [ Element.width Element.fill
        , Element.spacing viewSettings.spacing.xs
        , Border.widthEach
            { top = 0
            , right = 0
            , bottom = 5
            , left = 0
            }
        , Element.paddingEach
            { top = viewSettings.spacing.sm
            , right = 0
            , bottom = viewSettings.spacing.sm
            , left = 0
            }
        ]
        [ Element.paragraph
            [ Font.bold
            , Element.Region.heading 1
            , Font.size viewSettings.font.size.xl
            ]
            [ Element.text title ]
        , Element.el
            [ Font.size viewSettings.font.size.xs
            , Font.color viewSettings.font.color.secondary
            ]
          <|
            Element.text (Date.format "dd MMM yyyy" published)
        ]
