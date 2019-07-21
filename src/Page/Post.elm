module Page.Post exposing (Model, Msg, init, subscriptions, update, view)

import Config exposing (Config)
import Data.Post exposing (Post)
import Element exposing (Element)
import Layout.Page


type alias Model =
    { post : Post
    }


type alias Msg =
    ()


init : Post -> Model
init post =
    { post = post
    }


update : Msg -> Model -> ( Model, Cmd msg )
update () model =
    ( model, Cmd.none )



-- VIEW


view : Config -> Model -> { title : String, body : Element Msg }
view config model =
    { title = model.post.title
    , body =
        Layout.Page.view config
            { pageTitle = model.post.title
            , contentView = contentView config model
            }
    }


contentView : Config -> Model -> Element Msg
contentView config model =
    Element.el
        [ Element.paddingXY config.spacing.large config.spacing.medium
        , Element.alignTop
        , Element.height Element.fill
        ]
    <|
        Element.map never (model.post.content config)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
