module Main exposing (main)

import Browser
import Browser.Navigation as Navigation
import Element
import Element.Font as Font
import Menu
import Page.Home
import Page.QuadDivision
import Route exposing (Route)
import Url exposing (Url)


type alias Model =
    { navKey : Navigation.Key
    , menu : Menu.Model
    , page : PageModel
    }


type PageModel
    = Home
    | QuadDivision


type Msg
    = NavigateTo Url
    | ClickedLink Browser.UrlRequest
    | GoToRoute Route
    | MenuMsg Menu.Msg
    | HomeMsg Page.Home.Msg
    | QuadDivisionMsg Page.QuadDivision.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLink urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Navigation.pushUrl model.navKey (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Navigation.load url
                    )

        GoToRoute route ->
            ( model, goToRoute model.navKey route )

        NavigateTo url ->
            let
                ( page, cmd ) =
                    initPageFromUrl url
            in
            ( { model | page = page }, cmd )

        MenuMsg menuMsg ->
            ( { model | menu = Menu.update menuMsg model.menu }, Cmd.none )

        HomeMsg _ ->
            ( model, Cmd.none )

        QuadDivisionMsg _ ->
            ( model, Cmd.none )


goToRoute : Navigation.Key -> Route -> Cmd msg
goToRoute navKey route =
    Navigation.pushUrl navKey (Route.toUrlString route)


view : Model -> Browser.Document Msg
view model =
    let
        pageDocument =
            case model.page of
                Home ->
                    let
                        { title, body } =
                            Page.Home.view
                    in
                    { title = title
                    , body = Element.map HomeMsg body
                    }

                QuadDivision ->
                    let
                        { title, body } =
                            Page.QuadDivision.view
                    in
                    { title = title
                    , body = Element.map QuadDivisionMsg body
                    }
    in
    { title = pageDocument.title ++ " - danmarcab.com"
    , body =
        [ Element.layout
            [ Font.family
                [ Font.sansSerif
                ]
            , Element.inFront (Element.map MenuMsg <| Menu.view model.menu)
            ]
          <|
            Element.el
                [ Element.centerX
                , Element.centerY
                ]
                pageDocument.body
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        pageSubscriptions =
            case model.page of
                Home ->
                    Sub.none

                QuadDivision ->
                    Sub.none
    in
    Sub.batch
        [ pageSubscriptions
        , Sub.none
        ]


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        ( page, cmd ) =
            initPageFromUrl url

        ( menu, menuCmd ) =
            Menu.init
    in
    ( { navKey = navKey
      , menu = menu
      , page = page
      }
    , Cmd.batch
        [ cmd
        , Cmd.map MenuMsg menuCmd
        ]
    )


type alias Flags =
    ()


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , onUrlChange = NavigateTo
        , onUrlRequest = ClickedLink
        , subscriptions = subscriptions
        }


initPageFromUrl : Url -> ( PageModel, Cmd Msg )
initPageFromUrl url =
    case Route.parseUrl url of
        Route.Home ->
            ( Home, Cmd.none )

        Route.QuadDivision ->
            ( QuadDivision, Cmd.none )
