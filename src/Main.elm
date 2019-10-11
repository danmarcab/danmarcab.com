module Main exposing (main)

import Color
import Date
import Element exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Markdown
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


main : Pages.Platform.Program Model Msg Metadata Rendered
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


markdownDocument : ( String, Pages.Document.DocumentHandler Metadata Rendered )
markdownDocument =
    Pages.Document.parser
        { extension = "md"
        , metadata = Metadata.decoder
        , body =
            \markdownBody ->
                Html.div [] [ Markdown.toHtml [] markdownBody ]
                    |> Element.html
                    |> List.singleton
                    |> Element.paragraph [ Element.width Element.fill ]
                    |> Ok
        }


type alias Model =
    { viewSettings : ViewSettings
    }


init : ( Model, Cmd Msg )
init =
    ( { viewSettings = ViewSettings.default }
    , Cmd.none
    )


type alias Msg =
    ()


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> List ( PagePath Pages.PathKey, Metadata ) -> Page Metadata Rendered Pages.PathKey -> { title : String, body : Html Msg }
view model siteMetadata page =
    let
        { title, body } =
            pageView model siteMetadata page
    in
    { title = title
    , body =
        body
            |> Element.layout
                [ Element.width Element.fill
                , Element.height Element.fill
                , Font.size model.viewSettings.font.size.md
                , Font.family [ Font.typeface "Roboto" ]
                , Font.color model.viewSettings.font.color.primary
                , Background.color model.viewSettings.color.mainBackground
                ]
    }


pageView : Model -> List ( PagePath Pages.PathKey, Metadata ) -> Page Metadata Rendered Pages.PathKey -> { title : String, body : Element Msg }
pageView model siteMetadata page =
    case page.metadata of
        Metadata.Homepage metadata ->
            { title = metadata.title
            , body =
                Pages.Homepage.view
                    { viewSettings = model.viewSettings
                    , siteMetadata = siteMetadata
                    }
            }

        Metadata.Post metadata ->
            { title = metadata.title
            , body =
                Pages.Post.view
                    { viewSettings = model.viewSettings
                    , siteMetadata = siteMetadata
                    , page =
                        { path = page.path
                        , view = page.view
                        , metadata = metadata
                        }
                    }
            }

        Metadata.Project metadata ->
            { title = metadata.title
            , body =
                Pages.Project.view
                    { viewSettings = model.viewSettings
                    , siteMetadata = siteMetadata
                    , page =
                        { path = page.path
                        , view = page.view
                        , metadata = metadata
                        }
                    }
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
