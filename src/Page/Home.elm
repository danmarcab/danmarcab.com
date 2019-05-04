module Page.Home exposing (Model, Msg, init, subscriptions, update, view)

import Art.QuadDivision as QuadDivision
import Browser.Dom exposing (Viewport)
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html.Attributes
import Random
import Task


type Model
    = Initial
    | Started QuadDivision.Model


type Msg
    = Resized
    | InitSeed Int
    | Initialize Int Viewport


init : ( Model, Cmd Msg )
init =
    ( Initial
    , Random.generate InitSeed anyInt
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( Resized, _ ) ->
            ( model, Random.generate InitSeed anyInt )

        ( InitSeed seed, _ ) ->
            ( Initial
            , Task.perform (Initialize seed) Browser.Dom.getViewport
            )

        ( Initialize seed viewport, _ ) ->
            ( Started <|
                QuadDivision.generate
                    { initialSeed = seed
                    , viewport = viewport
                    , settings = QuadDivision.defaultSettings viewport
                    }
            , Cmd.none
            )


view : Model -> { title : String, body : Element Msg }
view model =
    { title = "Home"
    , body =
        case model of
            Started quadDivision ->
                Element.el
                    [ Element.width Element.fill
                    , Element.height Element.fill
                    , Element.inFront menuView
                    ]
                <|
                    Element.map never <|
                        Element.html (QuadDivision.view quadDivision)

            Initial ->
                Element.none
    }


menuView =
    let
        starting =
            False
    in
    Element.column
        [ Element.centerX
        , Element.centerY
        , Element.paddingXY 20 20
        , Background.color (Element.rgba255 0 0 0 0.9)
        , Font.color (Element.rgba255 255 255 255 1)
        , Border.roundEach { topLeft = 10, topRight = 10, bottomLeft = 10, bottomRight = 10 }
        , Element.spacing 20
        , Element.width (Element.fill |> Element.maximum 1000)
        , style "transform"
            (if starting then
                "scale(1.25)"

             else
                "scale(1)"
            )
        , style "transition" "transform 1s ease"
        ]
        [ Element.paragraph [ Font.size 25 ] [ Element.text "Welcome to danmarcab.com!" ]
        , Element.paragraph [ Font.size 20 ] [ Element.text "Here I will publish my blog and experiments about generative art and computer science (functional programming, compilers and more)." ]
        , Element.paragraph [ Font.size 20 ] [ Element.text "Right now, there is not much to see, but I hope to upload more stuff soon!" ]
        , cardView { url = "/quad-division", title = "Quad Division", imageUrl = "/images/quad-division.svg" }
        ]


cardView : { url : String, title : String, imageUrl : String } -> Element msg
cardView { url, title, imageUrl } =
    Element.link []
        { url = url
        , label =
            Element.column
                [ Element.padding 10
                , Background.color (Element.rgba255 255 255 255 0.2)
                , Element.spacing 10
                ]
                [ Element.el
                    [ Element.width (Element.px 200)
                    , Element.height (Element.px 100)
                    , Element.clip
                    ]
                  <|
                    Element.image
                        []
                        { src = imageUrl, description = title }
                , Element.el [ Element.centerX ] <| Element.text title
                ]
        }


style : String -> String -> Element.Attribute msg
style key val =
    Element.htmlAttribute (Html.Attributes.style key val)


subscriptions : Model -> Sub Msg
subscriptions fullModel =
    Sub.none



-- RANDOM GENERATORS


anyInt : Random.Generator Int
anyInt =
    Random.int Random.minInt Random.maxInt
