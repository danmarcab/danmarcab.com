module Main exposing (main)

import Browser.Dom
import Browser.Events
import Color
import Date
import Element exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Head
import Head.Seo as Seo
import Html exposing (Html)
import MarkdownRenderer
import Metadata exposing (Metadata)
import Pages exposing (images, pages)
import Pages.Document
import Pages.Homepage
import Pages.Manifest as Manifest
import Pages.Manifest.Category
import Pages.PagePath exposing (PagePath)
import Pages.Platform exposing (Page)
import Pages.Post
import Pages.Project
import Task
import ViewSettings exposing (ViewSettings)


manifest : Manifest.Config Pages.PathKey
manifest =
    { backgroundColor = Just Color.white
    , categories = [ Pages.Manifest.Category.education ]
    , displayMode = Manifest.Standalone
    , orientation = Manifest.Portrait
    , description = "My personal page and blog about Computer Science, Generative art and more."
    , iarcRatingId = Nothing
    , name = "danmarcab.com"
    , themeColor = Just Color.white
    , startUrl = pages.index
    , shortName = Just "danmarcab.com"
    , sourceIcon = images.icon
    }


type alias Rendered =
    Element Msg



-- the intellij-elm plugin doesn't support type aliases for Programs so we need to use this line
-- main : Platform.Program Pages.Platform.Flags (Pages.Platform.Model Model Msg Metadata Rendered) (Pages.Platform.Msg Msg Metadata Rendered)


main : Pages.Platform.Program Model Msg Metadata (ViewSettings -> Rendered)
main =
    Pages.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , documents = [ markdownDocument ]
        , head = head
        , manifest = manifest
        , canonicalSiteUrl = canonicalSiteUrl
        }


markdownDocument : ( String, Pages.Document.DocumentHandler Metadata (ViewSettings -> Rendered) )
markdownDocument =
    Pages.Document.parser
        { extension = "md"
        , metadata = Metadata.decoder
        , body =
            \content ->
                MarkdownRenderer.view content
                    |> Result.map
                        (\( toc, contents ) ->
                            \viewSettings ->
                                Element.column
                                    [ Element.spacing viewSettings.spacing.lg
                                    , Element.width Element.fill
                                    ]
                                    (List.map (\v -> v viewSettings) contents)
                        )
        }


type Model
    = Loading
    | Loaded LoadedModel


type alias LoadedModel =
    { viewSettings : ViewSettings
    }


init : ( Model, Cmd Msg )
init =
    ( Loading
    , Task.perform (\vp -> SizeChanged (round vp.scene.width) (round vp.scene.height)) Browser.Dom.getViewport
    )


type Msg
    = SizeChanged Int Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SizeChanged w h ->
            ( Loaded { viewSettings = ViewSettings.forSize w h }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Browser.Events.onResize SizeChanged


view :
    Model
    -> List ( PagePath Pages.PathKey, Metadata )
    -> Page Metadata (ViewSettings -> Rendered) Pages.PathKey
    -> { title : String, body : Html Msg }
view model siteMetadata page =
    case model of
        Loading ->
            loadingView

        Loaded loadedModel ->
            loadedView loadedModel siteMetadata page


loadedView :
    LoadedModel
    -> List ( PagePath Pages.PathKey, Metadata )
    -> Page Metadata (ViewSettings -> Rendered) Pages.PathKey
    -> { title : String, body : Html Msg }
loadedView model siteMetadata page =
    let
        { title, body, fillHeight } =
            pageView model siteMetadata page
    in
    { title = title
    , body =
        body
            |> Element.layout
                [ Element.width Element.fill
                , Element.height
                    (if fillHeight then
                        Element.fill

                     else
                        Element.shrink
                    )
                , Font.size model.viewSettings.font.size.md
                , Font.family [ Font.typeface "Roboto" ]
                , Font.color model.viewSettings.font.color.primary
                , Background.color model.viewSettings.color.mainBackground
                ]
    }


loadingView : { title : String, body : Html Msg }
loadingView =
    { title = "Loading..."
    , body = Html.text "Loading..."
    }


pageView :
    LoadedModel
    -> List ( PagePath Pages.PathKey, Metadata )
    -> Page Metadata (ViewSettings -> Rendered) Pages.PathKey
    -> { title : String, body : Element Msg, fillHeight : Bool }
pageView model siteMetadata page =
    case page.metadata of
        Metadata.Homepage metadata ->
            { title = metadata.title
            , body =
                Pages.Homepage.view
                    { viewSettings = model.viewSettings
                    , siteMetadata = siteMetadata
                    }
            , fillHeight = False
            }

        Metadata.Post metadata ->
            { title = metadata.title
            , body =
                Pages.Post.view
                    { viewSettings = model.viewSettings
                    , siteMetadata = siteMetadata
                    , page =
                        { path = page.path
                        , view = page.view model.viewSettings
                        , metadata = metadata
                        }
                    }
            , fillHeight = True
            }

        Metadata.Project metadata ->
            { title = metadata.title
            , body =
                Pages.Project.view
                    { viewSettings = model.viewSettings
                    , siteMetadata = siteMetadata
                    , page =
                        { path = page.path
                        , view = page.view model.viewSettings
                        , metadata = metadata
                        }
                    }
            , fillHeight = True
            }


{-| <https://developer.twitter.com/en/docs/tweets/optimize-with-cards/overview/abouts-cards>
<https://htmlhead.dev>
<https://html.spec.whatwg.org/multipage/semantics.html#standard-metadata-names>
<https://ogp.me/>
-}
head : Metadata -> List (Head.Tag Pages.PathKey)
head metadata =
    case metadata of
        Metadata.Homepage meta ->
            Seo.summary
                { canonicalUrlOverride = Nothing
                , siteName = "danmarcab.com"
                , image =
                    { url = images.icon
                    , alt = "danmarcab.com logo"
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = meta.description
                , locale = Nothing
                , title = meta.title
                }
                |> Seo.website

        Metadata.Post meta ->
            Seo.summaryLarge
                { canonicalUrlOverride = Nothing
                , siteName = "danmarcab.com"
                , image =
                    { url = meta.image
                    , alt = meta.description
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = meta.description
                , locale = Nothing
                , title = meta.title
                }
                |> Seo.article
                    { tags = []
                    , section = Nothing
                    , publishedTime = Just (Date.toIsoString meta.published)
                    , modifiedTime = Nothing
                    , expirationTime = Nothing
                    }

        Metadata.Project meta ->
            Seo.summaryLarge
                { canonicalUrlOverride = Nothing
                , siteName = "danmarcab.com"
                , image =
                    { url = meta.image
                    , alt = meta.description
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = meta.description
                , locale = Nothing
                , title = meta.title
                }
                |> Seo.website


canonicalSiteUrl : String
canonicalSiteUrl =
    "https://danmarcab.com"
