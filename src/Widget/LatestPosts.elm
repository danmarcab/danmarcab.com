module Widget.LatestPosts exposing (compact, expanded)

import Date
import Element exposing (Element)
import Element.Border as Border
import Element.Font as Font
import Metadata exposing (Metadata(..), PostMetadata)
import Pages
import Pages.PagePath as PagePath exposing (PagePath)
import ViewSettings exposing (ViewSettings)
import Widget.Card as Card


compact :
    ViewSettings
    ->
        { postsToShow : Int
        , siteMetadata : List ( PagePath Pages.PathKey, Metadata )
        }
    -> Element msg
compact viewSettings opts =
    let
        latestPosts =
            takePosts opts

        postLinkView ( path, post ) =
            Element.link []
                { url = PagePath.toString path
                , label = postView viewSettings Compact post
                }
    in
    Element.column
        [ Element.spacing viewSettings.spacing.sm
        , Element.width Element.fill
        ]
        [ listHeading viewSettings Compact
        , Element.column [ Element.spacing viewSettings.spacing.md ]
            (List.map postLinkView latestPosts)
        ]


expanded :
    ViewSettings
    ->
        { postsToShow : Int
        , siteMetadata : List ( PagePath Pages.PathKey, Metadata )
        }
    -> Element msg
expanded viewSettings opts =
    let
        latestPosts =
            takePosts opts

        postCardView ( path, post ) =
            Card.link viewSettings
                { url = PagePath.toString path
                , openInNewTab = False
                , content =
                    Element.el [ Element.padding viewSettings.spacing.md ] <|
                        postView viewSettings Expanded post
                }
    in
    Element.column
        [ Element.spacing viewSettings.spacing.md
        , Element.width Element.fill
        ]
        [ listHeading viewSettings Expanded
        , Element.column [ Element.spacing viewSettings.spacing.lg ]
            (List.map postCardView latestPosts)
        ]


type Mode
    = Compact
    | Expanded


modeDependent : Mode -> a -> a -> a
modeDependent mode compactValue expandedValue =
    case mode of
        Compact ->
            compactValue

        Expanded ->
            expandedValue


takePosts :
    { postsToShow : Int
    , siteMetadata : List ( PagePath Pages.PathKey, Metadata )
    }
    -> List ( PagePath Pages.PathKey, PostMetadata )
takePosts { postsToShow, siteMetadata } =
    List.filterMap
        (\( path, metadata ) ->
            case metadata of
                Metadata.Post meta ->
                    if meta.draft then
                        Nothing

                    else
                        Just ( path, meta )

                _ ->
                    Nothing
        )
        siteMetadata
        |> List.sortBy (\( _, { published } ) -> Date.toRataDie published)
        |> List.take postsToShow
        --        REMOVE
        |> List.repeat postsToShow
        |> List.concat


listHeading : ViewSettings -> Mode -> Element msg
listHeading viewSettings mode =
    Element.el
        [ Font.size (modeDependent mode viewSettings.font.size.md viewSettings.font.size.lg)
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
        Element.text "latest posts"


postView : ViewSettings -> Mode -> PostMetadata -> Element msg
postView viewSettings mode postMetadata =
    Element.column
        [ Element.spacing (modeDependent mode viewSettings.spacing.xs viewSettings.spacing.sm)
        ]
        [ Element.paragraph
            [ Font.size (modeDependent mode viewSettings.font.size.md viewSettings.font.size.lg)
            , Font.bold
            ]
            [ Element.text postMetadata.title
            ]
        , Element.el
            [ Font.size (modeDependent mode viewSettings.font.size.xs viewSettings.font.size.sm)
            , Font.color viewSettings.font.color.secondary
            ]
          <|
            Element.text <|
                Date.format "dd MMM yyyy" postMetadata.published
        , case mode of
            Compact ->
                Element.none

            Expanded ->
                Element.paragraph
                    [ Font.size viewSettings.font.size.md
                    ]
                    [ Element.text postMetadata.description
                    ]
        ]
