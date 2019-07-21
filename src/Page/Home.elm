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
        [ Element.paragraph [ Font.size 20 ]
            [ Element.text "Welcome! I am Daniel, a London based software engineer. I hope you have fun!"
            ]
        , Element.row
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


experimentsView : Config -> Element msg
experimentsView config =
    Element.column
        [ Element.spacing config.spacing.medium
        , Element.alignTop
        , Element.width (Element.fillPortion 1)
        ]
        [ header config "Experiments"
        , Element.paragraph [] [ Element.text "Coming soon..." ]
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
            [ Font.size 30
            , Font.bold
            ]
            [ Element.text text ]


postPreview : Config -> Post -> Element msg
postPreview config post =
    Element.column
        [ Element.spacing config.spacing.small
        , Element.width Element.fill
        ]
        [ Element.column
            [ Element.spacing config.spacing.tiny
            , Element.width Element.fill
            ]
            [ Element.link []
                { url = Route.toUrlString (Route.Post post.id)
                , label = postHeader config post.title
                }
            , Element.row
                [ Element.spacing config.spacing.medium
                , Font.size 16
                , Element.width Element.fill
                , Font.color config.colors.secondaryText
                ]
                [ let
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

                    startText =
                        if post.published then
                            "Published on "

                        else
                            "DRAFT!! To be published on "
                  in
                  Element.text <|
                    startText
                        ++ String.join " "
                            [ String.fromInt <| Time.toDay Time.utc post.publishedDate
                            , monthToString <| Time.toMonth Time.utc post.publishedDate
                            , String.fromInt <| Time.toYear Time.utc post.publishedDate
                            ]
                , Element.row [ Element.spacing config.spacing.tiny ]
                    (List.map
                        (\tag ->
                            Element.el
                                [ Font.color config.colors.primary
                                ]
                            <|
                                Element.text tag
                        )
                        post.tags
                        |> List.intersperse (Element.text "|")
                    )
                ]
            ]
        , Element.column [ Element.spacing config.spacing.small ]
            [ Element.paragraph [ Font.size 20 ] [ Element.text post.abstract ]
            , Element.link []
                { url = Route.toUrlString (Route.Post post.id)
                , label =
                    Element.el
                        [ Font.color config.colors.primary
                        ]
                    <|
                        Element.text "Read more >>"
                }
            ]
        ]


postHeader : Config -> String -> Element msg
postHeader config text =
    Element.paragraph
        [ Font.size 26
        , Font.bold
        , Font.color config.colors.primary
        ]
        [ Element.text text ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
