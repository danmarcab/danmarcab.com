module Page.QuadDivision exposing (Model, Msg, init, subscriptions, update, view)

import Art.QuadDivision as QuadDivision
import Browser.Dom exposing (Viewport)
import Browser.Events
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import FeatherIcons
import Random
import Task
import Time


type alias Model =
    { settings : Settings
    , settingsOpen : Bool
    , initialSeed : Int
    , internal : InternalModel
    }


type alias Settings =
    { updateEvery : Float
    }


type InternalModel
    = Initial
    | Started QuadDivision.Model


type Msg
    = Subdivide
    | Resized
    | InitSeed Int
    | Initialize Int Viewport
    | UpdateEveryChanged Float
    | InternalSettingChanged QuadDivision.SettingChange
    | Restart
    | OpenSettings
    | CloseSettings


init : ( Model, Cmd Msg )
init =
    ( { settings =
            { updateEvery = 100
            }
      , settingsOpen = False
      , initialSeed = 0
      , internal = Initial
      }
    , Random.generate InitSeed anyInt
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Subdivide ->
            ( case model.internal of
                Initial ->
                    model

                Started internal ->
                    { model | internal = Started (QuadDivision.subdivideStep internal) }
            , Cmd.none
            )

        Resized ->
            ( model, Random.generate InitSeed anyInt )

        InitSeed seed ->
            ( { model | internal = Initial }
            , Task.perform (Initialize seed) Browser.Dom.getViewport
            )

        Initialize seed viewport ->
            ( { model
                | internal =
                    Started <|
                        QuadDivision.initialize
                            { initialSeed = seed
                            , viewport = viewport
                            , settings = QuadDivision.defaultSettings viewport
                            }
              }
            , Cmd.none
            )

        UpdateEveryChanged newVal ->
            let
                oldSettings =
                    model.settings

                newSettings =
                    { oldSettings | updateEvery = newVal }
            in
            ( { model | settings = newSettings }
            , Cmd.none
            )

        InternalSettingChanged settingChange ->
            ( case model.internal of
                Initial ->
                    model

                Started internal ->
                    { model
                        | internal =
                            Started <|
                                QuadDivision.changeSetting settingChange internal
                    }
            , Cmd.none
            )

        Restart ->
            case model.internal of
                Initial ->
                    ( model, Random.generate InitSeed anyInt )

                Started internal ->
                    ( { model
                        | internal =
                            Started
                                (QuadDivision.restart internal)
                      }
                    , Cmd.none
                    )

        OpenSettings ->
            ( { model | settingsOpen = True }
            , Cmd.none
            )

        CloseSettings ->
            ( { model | settingsOpen = False }
            , Cmd.none
            )


view : Model -> { title : String, body : Element Msg }
view model =
    { title = "Quad Division"
    , body =
        case model.internal of
            Initial ->
                Element.text "Loading..."

            Started internal ->
                Element.el
                    [ Element.width Element.fill
                    , Element.height Element.fill
                    , Element.inFront (foregroundView model)
                    ]
                <|
                    Element.map never <|
                        Element.html (QuadDivision.view internal)
    }


foregroundView : Model -> Element Msg
foregroundView model =
    Element.column
        [ Element.spacing 10
        , Element.alignTop
        , Element.alignLeft
        ]
        [ headerView
        , settingsView model
        ]


headerView : Element Msg
headerView =
    Element.row
        [ Element.alignTop
        , Element.alignLeft
        , Element.paddingXY 20 10
        , Background.color (Element.rgba255 0 0 0 0.75)
        , Font.color (Element.rgba255 255 255 255 1)
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
            Element.text "Quad Division"
        ]


divider : Element Msg
divider =
    Element.el
        [ Border.color (Element.rgb 0.4 0.4 0.4)
        , Border.width 1
        , Element.height Element.fill
        ]
        Element.none


settingsView : Model -> Element Msg
settingsView model =
    Element.el
        [ Element.alignLeft
        , Element.centerY
        , Element.width Element.shrink
        , Background.color (Element.rgba255 0 0 0 0.8)
        , Font.color (Element.rgba255 255 255 255 1)
        , Border.roundEach { topLeft = 0, topRight = 10, bottomLeft = 0, bottomRight = 10 }
        ]
    <|
        if model.settingsOpen then
            openSettingsView model

        else
            Input.button [ Element.padding 10 ]
                { onPress = Just OpenSettings
                , label = icon FeatherIcons.settings
                }


openSettingsView : Model -> Element Msg
openSettingsView model =
    Element.column
        [ Element.spacing 20
        , Element.padding 20
        , Element.width (Element.px 350)
        ]
    <|
        [ Element.column [ Element.width Element.fill, Element.spacing 5 ]
            [ Element.row [ Element.width Element.fill ]
                [ Element.el [ Font.size 26 ] <| Element.text "Settings"
                , Input.button (buttonStyle ++ [ Element.alignRight, Element.alignTop ])
                    { onPress = Just CloseSettings, label = Element.text "Close" }
                ]
            , Element.paragraph [ Font.size 12 ]
                [ Element.text "Change the settings and see how they affect the result"
                ]
            ]
        , Element.column [ Element.width Element.fill, Element.spacing 5 ]
            [ Input.slider sliderStyle
                { onChange = UpdateEveryChanged
                , label =
                    Input.labelAbove []
                        (Element.text <|
                            "Subdivide Every ("
                                ++ String.fromFloat model.settings.updateEvery
                                ++ " ms)"
                        )
                , min = 50
                , max = 1000
                , value = model.settings.updateEvery
                , thumb = Input.defaultThumb
                , step = Just 25
                }
            , Element.paragraph [ Font.size 12 ]
                [ Element.text "How often to subdivide Quads"
                ]
            ]
        ]
            ++ internalSettingsView model.internal
            ++ [ Input.button buttonStyle
                    { onPress = Just Restart, label = Element.text "Restart" }
               ]


internalSettingsView : InternalModel -> List (Element Msg)
internalSettingsView internalModel =
    case internalModel of
        Started model ->
            let
                internalSettings =
                    QuadDivision.settings model
            in
            [ Element.column [ Element.width Element.fill, Element.spacing 5 ]
                [ Input.slider sliderStyle
                    { onChange = InternalSettingChanged << QuadDivision.ChangeSeparation
                    , label =
                        Input.labelAbove []
                            (Element.text <|
                                "Quad separation ("
                                    ++ String.fromFloat internalSettings.separation
                                    ++ " px)"
                            )
                    , min = 0
                    , max = 25
                    , value = internalSettings.separation
                    , thumb = Input.defaultThumb
                    , step = Just 1
                    }
                , Element.paragraph [ Font.size 12 ]
                    [ Element.text "Width of the gap between Quads"
                    ]
                ]
            , Element.column [ Element.width Element.fill, Element.spacing 5 ]
                [ Input.slider sliderStyle
                    { onChange = InternalSettingChanged << QuadDivision.ChangeMinArea
                    , label =
                        Input.labelAbove []
                            (Element.text <|
                                "Quad min area ("
                                    ++ String.fromFloat internalSettings.minArea
                                    ++ " px sq)"
                            )
                    , min = 5000
                    , max = 100000
                    , value = internalSettings.minArea
                    , thumb = Input.defaultThumb
                    , step = Just 5000
                    }
                , Element.paragraph [ Font.size 12 ]
                    [ Element.text "Minimum area a Quad needs to be divided"
                    ]
                ]
            , Element.column [ Element.width Element.fill, Element.spacing 5 ]
                [ Input.slider sliderStyle
                    { onChange = InternalSettingChanged << QuadDivision.ChangeMinSide
                    , label =
                        Input.labelAbove []
                            (Element.text <|
                                "Minimum side length ("
                                    ++ String.fromFloat internalSettings.minSide
                                    ++ " px)"
                            )
                    , min = 50
                    , max = 1000
                    , value = internalSettings.minSide
                    , thumb = Input.defaultThumb
                    , step = Just 50
                    }
                , Element.paragraph [ Font.size 12 ]
                    [ Element.text "Width of the gap between Quads. No need to restart."
                    ]
                ]
            ]

        Initial ->
            []


sliderStyle : List (Element.Attribute msg)
sliderStyle =
    [ Border.width 1
    , Border.color (Element.rgba255 255 255 255 0.5)
    , Background.color (Element.rgba255 255 255 255 0.05)
    ]


buttonStyle : List (Element.Attribute msg)
buttonStyle =
    [ Border.width 1
    , Border.color (Element.rgba255 255 255 255 0.5)
    , Background.color (Element.rgba255 255 255 255 0.05)
    , Element.padding 5
    , Element.alignRight
    ]


icon : FeatherIcons.Icon -> Element msg
icon i =
    i
        |> FeatherIcons.withSize 26
        |> FeatherIcons.withViewBox "0 0 26 26"
        |> FeatherIcons.toHtml []
        |> Element.html
        |> Element.el []


subscriptions : Model -> Sub Msg
subscriptions fullModel =
    let
        internalSubs =
            case fullModel.internal of
                Initial ->
                    Sub.none

                Started model ->
                    if QuadDivision.done model then
                        Sub.none

                    else
                        Time.every fullModel.settings.updateEvery (always Subdivide)
    in
    Sub.batch
        [ internalSubs
        , Browser.Events.onResize (\_ _ -> Resized)
        ]



-- RANDOM GENERATORS


anyInt : Random.Generator Int
anyInt =
    Random.int Random.minInt Random.maxInt
