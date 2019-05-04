module Page.QuadDivision exposing (Model, Msg, init, subscriptions, update, view)

import Art.QuadDivision as QuadDivision
import Browser.Dom exposing (Viewport)
import Browser.Events
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Random
import Task
import Time


type alias Model =
    { settings : Settings
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


init : ( Model, Cmd Msg )
init =
    ( { settings =
            { updateEvery = 100
            }
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
                    { model | internal = Started <| QuadDivision.changeSetting settingChange internal }
            , Cmd.none
            )

        Restart ->
            case model.internal of
                Initial ->
                    ( model, Random.generate InitSeed anyInt )

                Started internal ->
                    ( { model | internal = Started (QuadDivision.restart internal) }, Cmd.none )


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
                    , Element.inFront (settingsView model)
                    ]
                <|
                    Element.map never <|
                        Element.html (QuadDivision.view internal)
    }


settingsView : Model -> Element Msg
settingsView model =
    Element.el
        [ Element.alignLeft
        , Element.centerY
        , Element.width (Element.px 300)
        , Element.padding 20
        , Background.color (Element.rgba255 0 0 0 0.8)
        , Font.color (Element.rgba255 255 255 255 1)
        , Border.roundEach { topLeft = 0, topRight = 10, bottomLeft = 0, bottomRight = 10 }
        ]
    <|
        Element.column [ Element.spacing 20, Element.width Element.fill ] <|
            [ Element.el [ Font.size 26 ] <| Element.text "Settings"
            , -- TODO           Element.text "Step type (one | all)",
              Input.slider sliderStyle
                { onChange = UpdateEveryChanged
                , label =
                    Input.labelAbove []
                        (Element.text <| "Update Every (" ++ String.fromFloat model.settings.updateEvery ++ " ms)")
                , min = 50
                , max = 1000
                , value = model.settings.updateEvery
                , thumb = Input.defaultThumb
                , step = Just 25
                }
            ]
                ++ internalSettingsView model.internal
                ++ [ Input.button buttonStyle { onPress = Just Restart, label = Element.text "Restart" }
                   ]


internalSettingsView : InternalModel -> List (Element Msg)
internalSettingsView internalModel =
    case internalModel of
        Started model ->
            let
                internalSettings =
                    QuadDivision.settings model
            in
            [ Input.slider sliderStyle
                { onChange = InternalSettingChanged << QuadDivision.ChangeSeparation
                , label =
                    Input.labelAbove []
                        (Element.text <| "Separation (" ++ String.fromFloat internalSettings.separation ++ ")")
                , min = 1
                , max = 25
                , value = internalSettings.separation
                , thumb = Input.defaultThumb
                , step = Just 2
                }
            , Input.slider sliderStyle
                { onChange = InternalSettingChanged << QuadDivision.ChangeMinArea
                , label =
                    Input.labelAbove []
                        (Element.text <| "MinArea (" ++ String.fromFloat internalSettings.minArea ++ ")")
                , min = 5000
                , max = 100000
                , value = internalSettings.minArea
                , thumb = Input.defaultThumb
                , step = Just 5000
                }
            , Input.slider sliderStyle
                { onChange = InternalSettingChanged << QuadDivision.ChangeMinSide
                , label =
                    Input.labelAbove []
                        (Element.text <| "MinSide (" ++ String.fromFloat internalSettings.minSide ++ ")")
                , min = 50
                , max = 1000
                , value = internalSettings.minSide
                , thumb = Input.defaultThumb
                , step = Just 50
                }
            ]

        Initial ->
            []


sliderStyle =
    [ Border.width 1
    , Border.color (Element.rgba255 255 255 255 0.5)
    , Background.color (Element.rgba255 255 255 255 0.05)
    ]


buttonStyle =
    [ Border.width 1
    , Border.color (Element.rgba255 255 255 255 0.5)
    , Background.color (Element.rgba255 255 255 255 0.05)
    , Element.padding 5
    , Element.alignRight
    ]


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
        , Browser.Events.onResize (\w h -> Resized)
        ]



-- RANDOM GENERATORS


anyInt : Random.Generator Int
anyInt =
    Random.int Random.minInt Random.maxInt
