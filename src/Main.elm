module Main exposing (main)

import Browser
import Browser.Navigation as Navigation
import Config exposing (Config)
import Data.PostList as PostList exposing (PostList)
import Element
import Element.Background as Background
import Element.Font as Font
import Json.Decode as JD
import Menu
import Page.Home as Home
import Page.NotFound as NotFound
import Page.Post as Post
import Page.QuadDivision as QuadDivision
import Route
import Url exposing (Url)


type alias Model =
    { navKey : Navigation.Key
    , menu : Menu.Model
    , page : PageModel
    , posts : PostList
    , config : Config
    }


type PageModel
    = Home Home.Model
    | QuadDivision QuadDivision.Model
    | Post Post.Model
    | NotFound


type Msg
    = NavigateTo Url
    | ClickedLink Browser.UrlRequest
    | MenuMsg Menu.Msg
    | HomeMsg Home.Msg
    | PostMsg Post.Msg
    | QuadDivisionMsg QuadDivision.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Navigation.pushUrl model.navKey (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Navigation.load url
                    )

        ( NavigateTo url, _ ) ->
            let
                ( page, cmd ) =
                    initPageFromUrl model.posts url
            in
            ( { model | page = page }, cmd )

        ( MenuMsg menuMsg, _ ) ->
            ( { model | menu = Menu.update menuMsg model.menu }, Cmd.none )

        ( HomeMsg subMsg, Home pageModel ) ->
            let
                ( newModel, cmd ) =
                    Home.update subMsg pageModel
            in
            ( { model | page = Home newModel }, Cmd.map HomeMsg cmd )

        ( HomeMsg _, _ ) ->
            ( model, Cmd.none )

        ( PostMsg subMsg, Post pageModel ) ->
            let
                ( newModel, cmd ) =
                    Post.update subMsg pageModel
            in
            ( { model | page = Post newModel }, Cmd.map PostMsg cmd )

        ( PostMsg _, _ ) ->
            ( model, Cmd.none )

        ( QuadDivisionMsg subMsg, QuadDivision subModel ) ->
            let
                ( newModel, cmd ) =
                    QuadDivision.update subMsg subModel
            in
            ( { model | page = QuadDivision newModel }, Cmd.map QuadDivisionMsg cmd )

        ( QuadDivisionMsg _, _ ) ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    let
        ( showFloatingMenu, pageDocument ) =
            case model.page of
                Home pageModel ->
                    let
                        { title, body } =
                            Home.view model.config model.posts pageModel
                    in
                    ( False
                    , { title = title
                      , body = Element.map HomeMsg body
                      }
                    )

                Post pageModel ->
                    let
                        { title, body } =
                            Post.view model.config pageModel
                    in
                    ( False
                    , { title = title
                      , body = Element.map PostMsg body
                      }
                    )

                QuadDivision pageModel ->
                    let
                        { title, body } =
                            QuadDivision.view pageModel
                    in
                    ( True
                    , { title = title
                      , body = Element.map QuadDivisionMsg body
                      }
                    )

                NotFound ->
                    ( False, NotFound.view model.config )

        attrs =
            if showFloatingMenu then
                [ Element.inFront
                    (Element.map MenuMsg <|
                        Menu.view { pageTitle = pageDocument.title } model.menu
                    )
                ]

            else
                []
    in
    { title = pageDocument.title ++ " - danmarcab.com"
    , body =
        [ Element.layout
            ([ Font.family
                [ Font.typeface "Arial"
                ]
             , Background.color model.config.colors.mainBackground
             ]
                ++ attrs
            )
          <|
            Element.el
                [ Element.centerX
                , Element.centerY
                , Element.width Element.fill
                , Element.height Element.fill
                ]
                pageDocument.body
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        pageSubscriptions =
            case model.page of
                Home pageModel ->
                    Sub.map HomeMsg (Home.subscriptions pageModel)

                QuadDivision pageModel ->
                    Sub.map QuadDivisionMsg (QuadDivision.subscriptions pageModel)

                Post pageModel ->
                    Sub.map PostMsg (Post.subscriptions pageModel)

                NotFound ->
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
            initPageFromUrl posts url

        ( menu, menuCmd ) =
            Menu.init

        ( posts, _ ) =
            case JD.decodeValue PostList.decoder flags.unparsedPosts of
                Ok ( decodedPosts, [] ) ->
                    ( decodedPosts, "" )

                Ok ( decodedPosts, _ ) ->
                    ( decodedPosts, "" )

                Err _ ->
                    ( PostList.empty, "" )
    in
    ( { navKey = navKey
      , menu = menu
      , page = page
      , posts =
            if flags.showUnpublished then
                posts

            else
                PostList.filter .published posts
      , config =
            { colors = Config.lightModeColors
            , spacing = Config.desktopSpacing
            , fontSize = Config.desktopFontSize
            }
      }
    , Cmd.batch
        [ cmd
        , Cmd.map MenuMsg menuCmd
        ]
    )


type alias Flags =
    { showUnpublished : Bool
    , unparsedPosts : JD.Value
    }


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


initPageFromUrl : PostList -> Url -> ( PageModel, Cmd Msg )
initPageFromUrl posts url =
    case Route.parseUrl url of
        Route.Home ->
            let
                ( model, cmd ) =
                    Home.init
            in
            ( Home model, Cmd.map HomeMsg cmd )

        Route.Post postId ->
            case PostList.get postId posts of
                Just post ->
                    ( Post <| Post.init post, Cmd.none )

                Nothing ->
                    ( NotFound, Cmd.none )

        Route.QuadDivision ->
            let
                ( model, cmd ) =
                    QuadDivision.init
            in
            ( QuadDivision model, Cmd.map QuadDivisionMsg cmd )

        Route.NotFound ->
            ( NotFound, Cmd.none )
