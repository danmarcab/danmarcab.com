module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import Browser.Dom
import Browser.Events
import Browser.Navigation
import DataSource
import Element exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Html exposing (Html)
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Path exposing (Path)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import SyntaxHighlight
import Task
import View exposing (View)
import ViewSettings exposing (ViewSettings)


template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Just OnPageChange
    }


type Msg
    = OnPageChange
        { path : Path
        , query : Maybe String
        , fragment : Maybe String
        }
    | SharedMsg SharedMsg
    | SizeChanged Int Int


type alias Data =
    ()


type SharedMsg
    = NoOp


type alias Model =
    { showMobileMenu : Bool
    , viewSettings : ViewSettings
    }


init :
    Maybe Browser.Navigation.Key
    -> Pages.Flags.Flags
    ->
        Maybe
            { path :
                { path : Path
                , query : Maybe String
                , fragment : Maybe String
                }
            , metadata : route
            , pageUrl : Maybe PageUrl
            }
    -> ( Model, Cmd Msg )
init navigationKey flags maybePagePath =
    ( { showMobileMenu = False
      , viewSettings = ViewSettings.forSize 1920 1080
      }
    , Task.perform (\vp -> SizeChanged (round vp.scene.width) (round vp.scene.height)) Browser.Dom.getViewport
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnPageChange _ ->
            ( { model | showMobileMenu = False }
            , Cmd.batch
                [ Task.perform (\_ -> SharedMsg NoOp) (Browser.Dom.setViewport 0 0)
                , Task.attempt (\_ -> SharedMsg NoOp) (Browser.Dom.setViewportOf "post-content-container" 0 0)
                ]
            )

        SharedMsg _ ->
            ( model, Cmd.none )

        SizeChanged w h ->
            ( { model | viewSettings = ViewSettings.forSize w h }, Cmd.none )


subscriptions : Path -> Model -> Sub Msg
subscriptions _ _ =
    Browser.Events.onResize SizeChanged


data : DataSource.DataSource Data
data =
    DataSource.succeed ()


view :
    Data
    ->
        { path : Path
        , route : Maybe Route
        }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { body : Html msg, title : String }
view sharedData page model toMsg pageView =
    { title = pageView.title
    , body =
        Element.layout
            [ Element.width Element.fill
            , Element.height
                (if pageView.fillHeight then
                    Element.fill

                 else
                    Element.shrink
                )
            , Font.size model.viewSettings.font.size.md
            , Font.family [ Font.typeface "Roboto" ]
            , Font.color model.viewSettings.font.color.primary
            , Background.color model.viewSettings.color.mainBackground
            , Element.behindContent (Element.html <| SyntaxHighlight.useTheme SyntaxHighlight.monokai)
            ]
            pageView.body
    }
