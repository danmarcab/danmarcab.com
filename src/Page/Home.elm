module Page.Home exposing (Model, Msg, init, subscriptions, update, view)

import Config exposing (Config)
import Data.Post exposing (Post)
import Data.PostList as PostList exposing (PostList)
import Element exposing (Element)
import Element.Border as Border
import Element.Font as Font
import Layout.Page
import Route
import Time exposing (Month(..))


type alias Model =
    {}


type alias Msg =
    ()


init : ( Model, Cmd Msg )
init =
    ( {}
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update () model =
    ( model, Cmd.none )


view : Config -> PostList -> Model -> { title : String, body : Element Msg }
view config posts model =
    { title = "Home"
    , body =
        Layout.Page.view config
            { pageTitle = "Home"
            , contentView = contentView config posts model
            }
    }


contentView : Config -> PostList -> Model -> Element Msg
contentView config posts _ =
    Element.column
        [ Element.height Element.fill
        , Element.width Element.fill
        , Element.paddingXY config.spacing.large config.spacing.medium
        , Element.spacing config.spacing.medium
        ]
        [ Element.paragraph [ Font.size config.fontSize.medium ]
            [ Element.text "Welcome! I am Daniel, a London based software engineer. I hope you have fun!"
            ]
        , case config.device.class of
            Element.Phone ->
                Element.column
                    [ Element.width Element.fill
                    , Element.spacing config.spacing.large
                    ]
                    [ postsView config posts
                    , experimentsView config
                    ]

            _ ->
                Element.row
                    [ Element.width Element.fill
                    , Element.spacing config.spacing.large
                    ]
                    [ postsView config posts
                    , experimentsView config
                    ]
        ]


postsView : Config -> PostList -> Element msg
postsView config posts =
    Element.column
        [ Element.spacing config.spacing.medium
        , Element.alignTop
        , Element.width (Element.fillPortion 2)
        ]
        [ header config "Posts"
        , Element.column [ Element.spacing config.spacing.large ] <|
            PostList.map (postPreview config) posts
        ]


type alias Experiment =
    { title : String
    , abstract : String
    , url : String
    }


experiments : List Experiment
experiments =
    [ { title = "Quad Division"
      , abstract = "Create nice images by just randomly subdividing Quads."
      , url = Route.toUrlString Route.QuadDivision
      }
    ]


experimentsView : Config -> Element msg
experimentsView config =
    Element.column
        [ Element.spacing config.spacing.medium
        , Element.alignTop
        , Element.width (Element.fillPortion 1)
        ]
        [ header config "Experiments"
        , Element.column [ Element.spacing config.spacing.large ] <|
            List.map (experimentPreview config) experiments
        ]


experimentPreview : Config -> Experiment -> Element msg
experimentPreview config experiment =
    Element.column
        [ Element.spacing config.spacing.small
        , Element.width Element.fill
        ]
        [ Element.link []
            { url = experiment.url
            , label = postHeader config experiment.title
            }
        , Element.column [ Element.spacing config.spacing.small ]
            [ Element.paragraph
                [ Font.size config.fontSize.medium
                ]
                [ Element.text experiment.abstract ]
            , Element.image
                [ Element.width Element.fill, Element.centerX ]
                { src = "/images/quad-division.svg", description = experiment.title }
            , Element.link []
                { url = experiment.url
                , label =
                    Element.el
                        [ Font.color config.colors.primary
                        , Font.size config.fontSize.medium
                        ]
                    <|
                        Element.text "See more..."
                }
            ]
        ]


header : Config -> String -> Element msg
header config text =
    Element.el
        [ Border.widthEach { top = 0, bottom = 2, left = 0, right = 0 }
        , Border.color config.colors.tertiaryText
        , Element.width Element.fill
        , Element.paddingXY 0 config.spacing.tiny
        ]
    <|
        Element.paragraph
            [ Font.size config.fontSize.extraLarge
            , Font.bold
            ]
            [ Element.text text ]


postPreview : Config -> Post -> Element msg
postPreview config post =
    Element.column
        [ Element.spacing config.spacing.small
        , Element.width Element.fill
        ]
        [ postTitleView config post
        , Element.column
            [ Element.spacing config.spacing.small
            ]
            [ Element.paragraph
                [ Font.size config.fontSize.medium
                ]
                [ Element.text post.abstract ]
            , Element.link []
                { url = Route.toUrlString (Route.Post post.id)
                , label =
                    Element.el
                        [ Font.color config.colors.primary
                        , Font.size config.fontSize.medium
                        ]
                    <|
                        Element.text "Read more..."
                }
            ]
        ]


postTitleView : Config -> Post -> Element msg
postTitleView config post =
    let
        headerLink =
            Element.link []
                { url = Route.toUrlString (Route.Post post.id)
                , label = postHeader config post.title
                }

        startText =
            if post.published then
                ""

            else
                "DRAFT!! "

        publishedDate =
            Element.text <|
                startText
                    ++ String.join " "
                        [ String.fromInt <| Time.toDay Time.utc post.publishedDate
                        , monthToString <| Time.toMonth Time.utc post.publishedDate
                        , String.fromInt <| Time.toYear Time.utc post.publishedDate
                        ]

        tags =
            List.map
                (\tag ->
                    Element.el
                        [ Font.color config.colors.primary
                        , Border.width 1
                        , Element.padding config.spacing.tiny
                        , Border.rounded config.spacing.tiny
                        ]
                    <|
                        Element.text tag
                )
                post.tags
    in
    Element.column
        [ Element.spacing config.spacing.tiny
        , Element.width Element.fill
        , Font.size config.fontSize.small
        , Font.color config.colors.secondaryText
        ]
    <|
        [ headerLink
        , Element.wrappedRow
            [ Element.spacingXY config.spacing.small config.spacing.tiny
            , Element.width Element.fill
            ]
            (publishedDate :: tags)
        ]


monthToString : Month -> String
monthToString month =
    case month of
        Jan ->
            "Jan"

        Feb ->
            "Feb"

        Mar ->
            "Mar"

        Apr ->
            "Apr"

        May ->
            "May"

        Jun ->
            "Jun"

        Jul ->
            "Jul"

        Aug ->
            "Aug"

        Sep ->
            "Sep"

        Oct ->
            "Oct"

        Nov ->
            "Nov"

        Dec ->
            "Dec"


postHeader : Config -> String -> Element msg
postHeader config text =
    Element.paragraph
        [ Font.size config.fontSize.large
        , Font.bold
        , Font.color config.colors.primary
        ]
        [ Element.text text ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
