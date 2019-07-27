module Page.QuadDivision exposing (Model, Msg, init, resize, subscriptions, update, view)

import Art.QuadDivision as QuadDivision
import Config exposing (Config)
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import FeatherIcons
import Ports
import Random
import Time


type alias Model =
    { settings : Settings
    , settingsOpen : Bool
    , fullScreen : Bool
    , running : Bool
    , internal : QuadDivision.Model
    }


type alias Settings =
    { updateEvery : Float
    }


type Msg
    = Tick
    | InitSeed Int
    | UpdateEveryChanged Float
    | InternalSettingChanged QuadDivision.SettingChange
    | Pause
    | Resume
    | Restart
    | OpenSettings
    | CloseSettings
    | EnterFullScreen
    | ExitFullScreen
    | DownloadSvg


init : Config -> ( Model, Cmd Msg )
init config =
    ( { settings =
            { updateEvery = 100
            }
      , settingsOpen = False
      , fullScreen = False

      -- this should be false but set to True due to a bug with subscriptions not triggering
      , running = True
      , internal =
            QuadDivision.initialize
                { initialSeed = 1
                , viewport = config.viewport
                , settings = QuadDivision.defaultSettings config.viewport
                }
      }
    , Random.generate InitSeed anyInt
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick ->
            if QuadDivision.done model.internal then
                ( { model | running = False }
                , Cmd.none
                )

            else
                ( { model | internal = QuadDivision.subdivideStep model.internal }
                , Cmd.none
                )

        InitSeed seed ->
            ( { model | internal = QuadDivision.setSeed seed model.internal, running = True }
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
            ( { model | internal = QuadDivision.changeSetting settingChange model.internal }
            , Cmd.none
            )

        Pause ->
            ( { model | running = False }
            , Cmd.none
            )

        Resume ->
            ( { model | running = True }
            , Cmd.none
            )

        Restart ->
            ( { model | internal = QuadDivision.restart model.internal, running = True }
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

        EnterFullScreen ->
            ( { model | fullScreen = True }
            , Cmd.none
            )

        ExitFullScreen ->
            ( { model | fullScreen = False }
            , Cmd.none
            )

        DownloadSvg ->
            ( model
            , Ports.downloadSvg "quad-division"
            )


resize : { width : Int, height : Int } -> Model -> Model
resize viewport model =
    { model | internal = QuadDivision.resize viewport model.internal, running = True }


view : Config -> Model -> { title : String, body : Element Msg }
view config model =
    { title = "Quad Division"
    , body =
        Element.el
            [ Element.width Element.fill
            , Element.height Element.fill
            , Element.inFront (foregroundView config model)
            ]
        <|
            Element.map never <|
                Element.html (QuadDivision.view model.internal)
    }


foregroundView : Config -> Model -> Element Msg
foregroundView config model =
    let
        header =
            if model.fullScreen then
                Element.none

            else
                Element.el
                    [ Element.alignTop
                    , Element.alignLeft
                    ]
                <|
                    headerView config

        settings =
            if model.fullScreen then
                Element.none

            else
                alignedRight <| settingsView config model

        controls =
            alignedRight <| controlsView config model

        alignedRight el =
            Element.el [ Element.alignRight ] el

        responsive =
            case config.device.class of
                Element.Phone ->
                    { layoutDirection = Element.column
                    , menuAlignment = Element.alignBottom
                    , menuItems =
                        [ settings
                        , controls
                        ]
                    }

                Element.Tablet ->
                    { layoutDirection = Element.column
                    , menuAlignment = Element.alignBottom
                    , menuItems =
                        [ settings
                        , controls
                        ]
                    }

                _ ->
                    { layoutDirection = Element.row
                    , menuAlignment = Element.alignTop
                    , menuItems =
                        [ controls
                        , settings
                        ]
                    }
    in
    responsive.layoutDirection
        [ Element.alignTop
        , Element.width Element.fill
        , Element.height Element.fill
        ]
        [ header
        , Element.column
            [ responsive.menuAlignment
            , Element.alignRight
            , Element.spacing config.spacing.tiny
            ]
            responsive.menuItems
        ]


headerView : Config -> Element Msg
headerView config =
    Element.row
        [ Element.alignTop
        , Element.alignLeft
        , Element.paddingXY config.spacing.large config.spacing.small
        , Background.color (Element.rgba255 0 0 0 0.75)
        , Font.color (Element.rgba255 255 255 255 1)
        , Border.roundEach
            { topLeft = 0
            , topRight = 0
            , bottomLeft = 0
            , bottomRight = config.spacing.small
            }
        , Element.spacing config.spacing.medium
        , Font.size config.fontSize.large
        , Font.bold
        ]
        [ Element.link []
            { url = "/"
            , label = Element.el [] <| Element.text "danmarcab.com"
            }
        , divider
        , Element.el [] <| Element.text "Quad Division"
        ]


controlsView : Config -> Model -> Element Msg
controlsView config model =
    let
        button msg iconType =
            Input.button [ Element.padding config.spacing.small ]
                { onPress = Just msg
                , label = icon iconType
                }

        restartButton =
            button Restart FeatherIcons.refreshCw

        downloadButton =
            button DownloadSvg FeatherIcons.download

        pauseButton =
            button Pause FeatherIcons.pause

        resumeButton =
            button Resume FeatherIcons.play

        settingsButton =
            button
                (if model.settingsOpen then
                    CloseSettings

                 else
                    OpenSettings
                )
                FeatherIcons.settings

        enterFullScreenButton =
            button EnterFullScreen FeatherIcons.maximize

        exitFullScreenButton =
            button ExitFullScreen FeatherIcons.minimize

        buttons =
            if model.fullScreen then
                [ exitFullScreenButton ]

            else
                [ restartButton
                , if QuadDivision.done model.internal then
                    downloadButton

                  else if model.running then
                    pauseButton

                  else
                    resumeButton
                , settingsButton
                , enterFullScreenButton
                ]

        responsive =
            case config.device.class of
                Element.Phone ->
                    { border =
                        Border.roundEach
                            { topLeft = config.spacing.small
                            , topRight = 0
                            , bottomLeft = 0
                            , bottomRight = 0
                            }
                    }

                _ ->
                    { border =
                        Border.roundEach
                            { topLeft = 0
                            , topRight = 0
                            , bottomLeft = config.spacing.small
                            , bottomRight = 0
                            }
                    }
    in
    Element.row
        [ Element.paddingXY config.spacing.small 0
        , Background.color (Element.rgba255 0 0 0 0.75)
        , Font.color (Element.rgba255 255 255 255 1)
        , responsive.border
        , Font.size config.fontSize.large
        , Font.bold
        ]
        buttons


divider : Element Msg
divider =
    Element.el
        [ Border.color (Element.rgb 0.4 0.4 0.4)
        , Border.width 1
        , Element.height Element.fill
        ]
        Element.none


settingsView : Config -> Model -> Element Msg
settingsView config model =
    Element.el
        [ Element.alignLeft
        , Element.centerY
        , Element.width Element.shrink
        , Background.color (Element.rgba255 0 0 0 0.8)
        , Font.color (Element.rgba255 255 255 255 1)
        , Border.roundEach
            { topLeft = config.spacing.small
            , topRight = 0
            , bottomLeft = config.spacing.small
            , bottomRight = 0
            }
        , Font.size config.fontSize.medium
        ]
    <|
        if model.settingsOpen then
            openSettingsView config model

        else
            Element.none


openSettingsView : Config -> Model -> Element Msg
openSettingsView config model =
    Element.column
        [ Element.spacing config.spacing.medium
        , Element.padding config.spacing.medium
        , Element.width Element.shrink
        ]
    <|
        [ Element.column
            [ Element.width Element.fill
            , Element.spacing config.spacing.tiny
            ]
            [ Element.row [ Element.width Element.fill ]
                [ Element.el [ Font.size config.fontSize.large ] <|
                    Element.text "Settings"
                , Input.button (buttonStyle ++ [ Element.alignRight, Element.alignTop ])
                    { onPress = Just CloseSettings, label = Element.text "Close" }
                ]
            , Element.paragraph [ Font.size config.fontSize.small ]
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
            , Element.paragraph [ Font.size config.fontSize.small ]
                [ Element.text "How often to subdivide Quads"
                ]
            ]
        ]
            ++ internalSettingsView config model.internal


internalSettingsView : Config -> QuadDivision.Model -> List (Element Msg)
internalSettingsView config model =
    let
        internalSettings =
            QuadDivision.settings model
    in
    [ Element.column [ Element.width Element.fill, Element.spacing config.spacing.tiny ]
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
        , Element.paragraph [ Font.size config.fontSize.small ]
            [ Element.text "Width of the gap between Quads"
            ]
        ]
    , Element.column [ Element.width Element.fill, Element.spacing config.spacing.tiny ]
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
        , Element.paragraph [ Font.size config.fontSize.small ]
            [ Element.text "Minimum area a Quad needs to be divided"
            ]
        ]
    , Element.column [ Element.width Element.fill, Element.spacing config.spacing.tiny ]
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
        , Element.paragraph [ Font.size config.fontSize.small ]
            [ Element.text "Width of the gap between Quads"
            ]
        ]
    ]


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
subscriptions model =
    if model.running then
        Time.every model.settings.updateEvery (always Tick)

    else
        Sub.none



-- RANDOM GENERATORS


anyInt : Random.Generator Int
anyInt =
    Random.int Random.minInt Random.maxInt
