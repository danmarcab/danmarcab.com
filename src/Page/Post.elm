module Page.Post exposing (Model, Msg, init, subscriptions, update, view)

import Data.Post as Post exposing (Post)
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Layout.Page
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
        Layout.Page.view { colorScheme = colorScheme }
            { pageTitle = model.post.title
            , contentView = contentView { colorScheme = colorScheme } model
            }
    }


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
