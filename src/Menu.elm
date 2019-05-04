module Menu exposing (Model(..), Msg(..), init, update, view)

import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html.Attributes
import Process
import Task


type Model
    = Menu
        { starting : Bool
        }


type Msg
    = Started


update : Msg -> Model -> Model
update msg (Menu menu) =
    case msg of
        Started ->
            Menu { menu | starting = False }


view : { pageTitle : String } -> Model -> Element Msg
view { pageTitle } (Menu { starting }) =
    Element.row
        [ Element.alignTop
        , Element.alignLeft
        , Element.paddingXY 20 10
        , Background.color (Element.rgba255 0 0 0 0.75)
        , Font.color (Element.rgba255 255 255 255 1)
        , Border.roundEach { topLeft = 0, topRight = 0, bottomLeft = 0, bottomRight = 10 }
        , Element.spacing 20
        , style "transform"
            (if starting then
                "scale(1.25)"

             else
                "scale(1)"
            )
        , style "transform-origin" "top left"
        , style "transition" "transform 1s ease"
        ]
        [ Element.link []
            { url = "/"
            , label =
                Element.el
                    [ Font.bold
                    , Font.size 25
                    ]
                <|
                    Element.text "danmarcab.com"
            }
        , divider
        , Element.el
            [ Font.bold
            , Font.size 25
            ]
          <|
            Element.text pageTitle
        ]


divider : Element Msg
divider =
    Element.el
        [ Border.color (Element.rgb 0.4 0.4 0.4)
        , Border.width 1
        , Element.height Element.fill
        ]
        Element.none


style : String -> String -> Element.Attribute msg
style key val =
    Element.htmlAttribute (Html.Attributes.style key val)


init : ( Model, Cmd Msg )
init =
    ( Menu { starting = True }
    , Task.perform (\() -> Started) (Process.sleep 1000)
    )
