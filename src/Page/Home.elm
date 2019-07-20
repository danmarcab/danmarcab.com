module Page.Home exposing (Model, Msg, init, subscriptions, update, view)

import Data.Post as Post exposing (Post)
import Data.PostList as PostList exposing (PostList)
import Element exposing (Element)
import Element.Border as Border
import Element.Font as Font
import Layout.Page
import Route exposing (Route)
import Style.Color as Color


type alias Model =
    {}


type Msg
    = NoOp


init : ( Model, Cmd Msg )
init =
    ( {}
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


view : { colorScheme : Color.Scheme } -> PostList -> Model -> { title : String, body : Element Msg }
view { colorScheme } posts model =
    { title = "Home"
    , body =
        Layout.Page.view { colorScheme = colorScheme }
            { pageTitle = "Home"
            , contentView = contentView { colorScheme = colorScheme } posts model
            }
    }


contentView : { colorScheme : Color.Scheme } -> PostList -> Model -> Element Msg
contentView { colorScheme } posts model =
    Element.column
        [ Element.height Element.fill
        , Element.width Element.fill
        , Element.paddingXY 40 20
        , Border.roundEach { topLeft = 10, topRight = 10, bottomLeft = 10, bottomRight = 10 }
        , Element.spacing 20
        ]
        [ Element.paragraph [ Font.size 20 ]
            [ Element.text "Welcome! I am Daniel, a London based software engineer. I hope you have fun!"
            ]
        , Element.row
            [ Element.width Element.fill
            , Element.spacing 40
            ]
            [ postsView { colorScheme = colorScheme } posts
            , experimentsView { colorScheme = colorScheme }
            ]
        ]


postsView : { colorScheme : Color.Scheme } -> PostList -> Element msg
postsView { colorScheme } posts =
    Element.column
        [ Element.spacing 20
        , Element.alignTop
        , Element.width (Element.fillPortion 2)
        ]
        [ header { colorScheme = colorScheme } "Posts"
        , Element.column [ Element.spacing 30 ] <|
            PostList.map (postPreview { colorScheme = colorScheme }) posts
        ]


experimentsView : { colorScheme : Color.Scheme } -> Element msg
experimentsView { colorScheme } =
    Element.column
        [ Element.spacing 20
        , Element.alignTop
        , Element.width (Element.fillPortion 1)
        ]
        [ header { colorScheme = colorScheme } "Experiments"
        , Element.paragraph [] [ Element.text "Coming soon..." ]
        ]


header : { colorScheme : Color.Scheme } -> String -> Element msg
header { colorScheme } text =
    Element.el
        [ Border.widthEach { top = 0, bottom = 2, left = 0, right = 0 }
        , Border.color (Color.contentBorder colorScheme)
        , Element.width Element.fill
        , Element.paddingXY 0 5
        ]
    <|
        Element.paragraph
            [ Font.size 30
            , Font.bold
            ]
            [ Element.text text ]


postPreview : { colorScheme : Color.Scheme } -> Post -> Element msg
postPreview { colorScheme } post =
    Element.column
        [ Element.spacing 10
        , Element.width Element.fill
        ]
        [ Element.column
            [ Element.spacing 5
            , Element.width Element.fill
            ]
            [ Element.link []
                { url = Route.toUrlString (Route.Post post.id)
                , label = postHeader { colorScheme = colorScheme } post.title
                }
            , Element.row
                [ Element.spacing 20
                , Font.size 16
                , Element.width Element.fill
                , Font.color (Color.secondaryText colorScheme)
                ]
                [ let
                    ( y, m, d ) =
                        post.publishedDate

                    startText =
                        if post.published then
                            "Published on "

                        else
                            "DRAFT!! To be published on "
                  in
                  Element.text <|
                    startText
                        ++ String.join "/"
                            [ String.fromInt d, String.fromInt m, String.fromInt y ]
                , Element.row [ Element.spacing 5 ]
                    (List.map
                        (\tag ->
                            Element.el
                                [ Font.color (Color.primary colorScheme)
                                ]
                            <|
                                Element.text tag
                        )
                        post.tags
                        |> List.intersperse (Element.text "|")
                    )
                ]
            ]
        , Element.column [ Element.spacing 10 ]
            [ Element.paragraph [ Font.size 20 ] [ Element.text post.abstract ]
            , Element.link []
                { url = Route.toUrlString (Route.Post post.id)
                , label =
                    Element.el
                        [ Font.color (Color.primary colorScheme)
                        ]
                    <|
                        Element.text "Read more >>"
                }
            ]
        ]


postHeader : { colorScheme : Color.Scheme } -> String -> Element msg
postHeader { colorScheme } text =
    Element.paragraph
        [ Font.size 26
        , Font.bold
        , Font.color (Color.primary colorScheme)
        ]
        [ Element.text text ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
