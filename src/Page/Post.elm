module Page.Post exposing (Model, Msg, init, subscriptions, update, view)

import Data.Post as Post exposing (Post)
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Style.Color as Color


type alias Model =
    { post : Post
    }


type Msg
    = NoOp


init : Post -> Model
init post =
    { post = post
    }


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    ( model, Cmd.none )



-- VIEW


view : { colorScheme : Color.Scheme } -> Model -> { title : String, body : Element Msg }
view { colorScheme } model =
    { title = model.post.title
    , body =
        Element.column
            [ Element.width (Element.px 1000)
            , Element.centerX
            , Border.shadow
                { blur = 5
                , color = Color.contentBorder colorScheme
                , offset = ( 0, 0 )
                , size = 0
                }
            , Element.height Element.fill
            , Background.color (Color.contentBackground colorScheme)
            , Font.color (Color.contentFont colorScheme)
            ]
            [ menuView { colorScheme = colorScheme } model
            , contentView { colorScheme = colorScheme } model
            ]
    }


menuView : { colorScheme : Color.Scheme } -> Model -> Element Msg
menuView { colorScheme } model =
    Element.row
        [ Element.alignTop
        , Element.alignLeft
        , Element.paddingXY 20 10
        , Background.color (Color.primary colorScheme)
        , Font.color Color.white
        , Border.roundEach { topLeft = 0, topRight = 0, bottomLeft = 0, bottomRight = 10 }
        , Element.spacing 20
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
            Element.text model.post.title
        ]


divider : Element Msg
divider =
    Element.el
        [ Border.color Color.white
        , Border.width 1
        , Element.height Element.fill
        ]
        Element.none


contentView : { colorScheme : Color.Scheme } -> Model -> Element Msg
contentView { colorScheme } model =
    Element.el
        [ Element.paddingXY 40 20
        , Element.alignTop
        , Element.height Element.fill
        ]
    <|
        Element.map never (model.post.content colorScheme)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
