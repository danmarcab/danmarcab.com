module Page.QuadDivision exposing (Model, Msg, init, subscriptions, update, view)

import Art.QuadDivision as QuadDivision
import Config exposing (Config)
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import FeatherIcons
import Random
import Time


type alias Model =
    { settings : Settings
    , settingsOpen : Bool
    , initialSeed : Int
    , internal : InternalModel
    , viewport : Viewport
    }


type alias Viewport =
    { width : Int
    , height : Int
    }


type alias Settings =
    { updateEvery : Float
    }


type InternalModel
    = Initial
    | Started QuadDivision.Model


type Msg
    = Subdivide
    | InitSeed Int
    | UpdateEveryChanged Float
    | InternalSettingChanged QuadDivision.SettingChange
    | Restart
    | OpenSettings
    | CloseSettings


init : Config -> ( Model, Cmd Msg )
init config =
    ( { settings =
            { updateEvery = 100
            }
      , settingsOpen = False
      , initialSeed = 0
      , internal = Initial
      , viewport = config.viewport
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

        InitSeed seed ->
            ( { model
                | internal =
                    Started <|
                        QuadDivision.initialize
                            { initialSeed = seed
                            , viewport = model.viewport
                            , settings = QuadDivision.defaultSettings model.viewport
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


view : Config -> Model -> { title : String, body : Element Msg }
view config model =
    { title = "Quad Division"
    , body =
        case model.internal of
            Initial ->
                Element.text "Loading..."

            Started internal ->
                Element.el
                    [ Element.width Element.fill
                    , Element.height Element.fill
                    , Element.inFront (foregroundView config model)
                    ]
                <|
                    Element.map never <|
                        Element.html (QuadDivision.view internal)
    }


foregroundView : Config -> Model -> Element Msg
foregroundView config model =
    Element.column
        [ Element.spacing config.spacing.small
        , Element.alignTop
        , Element.alignLeft
        ]
        [ headerView config
        , settingsView config model
        ]


headerView : Config -> Element Msg
headerView config =
    Element.row
        [ Element.alignTop
        , Element.alignLeft
        , Element.paddingXY config.spacing.large config.spacing.small
        , Background.color (Element.rgba255 0 0 0 0.75)
        , Font.color (Element.rgba255 255 255 255 1)
        , Border.roundEach { topLeft = 0, topRight = 0, bottomLeft = 0, bottomRight = config.spacing.small }
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
            { topLeft = 0
            , topRight = config.spacing.small
            , bottomLeft = 0
            , bottomRight = config.spacing.small
            }
        , Font.size config.fontSize.medium
        ]
    <|
        if model.settingsOpen then
            openSettingsView config model

        else
            Input.button [ Element.padding config.spacing.small ]
                { onPress = Just OpenSettings
                , label = icon FeatherIcons.settings
                }


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
            ++ [ Input.button buttonStyle
                    { onPress = Just Restart, label = Element.text "Restart" }
               ]


internalSettingsView : Config -> InternalModel -> List (Element Msg)
internalSettingsView config internalModel =
    case internalModel of
        Started model ->
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
    case fullModel.internal of
        Initial ->
            Sub.none

        Started model ->
            if QuadDivision.done model then
                Sub.none

            else
                Time.every fullModel.settings.updateEvery (always Subdivide)



-- RANDOM GENERATORS


anyInt : Random.Generator Int
anyInt =
    Random.int Random.minInt Random.maxInt
