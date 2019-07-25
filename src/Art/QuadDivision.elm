module Art.QuadDivision exposing
    ( Model
    , SettingChange(..)
    , Settings
    , changeSetting
    , defaultSettings
    , done
    , generate
    , initialize
    , restart
    , settings
    , subdivideStep
    , view
    )

import Array
import Art.QuadDivision.Quad as Quad exposing (Quad)
import Random
import Svg exposing (Svg)
import Svg.Attributes
import Svg.Lazy
import Util.Batcher as Batcher exposing (Batcher)
import Util.Collection as Collection exposing (Collection)



-- SETTINGS


type alias Settings =
    { separation : Float
    , minSide : Float
    , minArea : Float
    }


settings : Model -> Settings
settings (Model model) =
    model.settings


defaultSettings : Viewport -> Settings
defaultSettings viewport =
    let
        separation =
            min viewport.width viewport.height
                |> toFloat
                |> (\num -> num / 1000.0)
                |> round
                |> max 1
                |> (\num -> num * 5)
                |> toFloat
    in
    { separation = separation
    , minSide = separation * 20
    , minArea = separation * separation * 1000
    }


type SettingChange
    = ChangeSeparation Float
    | ChangeMinSide Float
    | ChangeMinArea Float


changeSetting : SettingChange -> Model -> Model
changeSetting change (Model model) =
    let
        oldSettings =
            model.settings

        newSettings =
            case change of
                ChangeSeparation newSeparation ->
                    { oldSettings | separation = newSeparation }

                ChangeMinSide newMinSide ->
                    { oldSettings | minSide = newMinSide }

                ChangeMinArea newMinArea ->
                    { oldSettings | minArea = newMinArea }
    in
    Model { model | settings = newSettings }



-- MODEL


type Model
    = Model
        { seed : Random.Seed
        , quads : Collection Quad
        , quadBatcher : Batcher Quad
        , settings : Settings
        , viewport : Viewport
        }


type alias Viewport =
    { width : Int
    , height : Int
    }


initialize : { settings : Settings, initialSeed : Int, viewport : Viewport } -> Model
initialize params =
    Model
        { seed = Random.initialSeed params.initialSeed
        , quads = Collection.empty
        , quadBatcher = Batcher.new 100
        , viewport = params.viewport
        , settings = params.settings
        }
        |> restart


generate : { settings : Settings, initialSeed : Int, viewport : Viewport } -> Model
generate params =
    let
        loop model =
            if done model then
                model

            else
                subdivideStep model
                    |> loop
    in
    initialize params
        |> loop


restart : Model -> Model
restart (Model model) =
    let
        ( initialQuad, seed2 ) =
            Random.step
                (Quad.initialQuadGenerator
                    { width = toFloat model.viewport.width
                    , height = toFloat model.viewport.height
                    }
                )
                model.seed
    in
    Model
        { seed = seed2
        , quads = Collection.fromItems [ initialQuad ]
        , quadBatcher = Batcher.new 100
        , viewport = model.viewport
        , settings = model.settings
        }


done : Model -> Bool
done (Model { quads }) =
    Collection.isEmpty quads


subdivideStep : Model -> Model
subdivideStep (Model model) =
    let
        ( indexToSubdivide, newSeed ) =
            Random.step
                (Random.weighted ( 0.001, 0 )
                    (List.map (\idx -> ( 1, idx )) (Collection.indices model.quads))
                )
                model.seed
    in
    case Collection.get indexToSubdivide model.quads of
        Just quad ->
            let
                ( nextSeed, dividedQuads ) =
                    Quad.subdivide newSeed model.settings quad

                ( divisibleQuads, staticQuads ) =
                    List.partition (Quad.canSubdivide model.settings) dividedQuads
            in
            Model
                { model
                    | seed = nextSeed
                    , quads = Collection.insertMany divisibleQuads (Collection.remove indexToSubdivide model.quads)
                    , quadBatcher = Batcher.addMany staticQuads model.quadBatcher
                }

        Nothing ->
            Model { model | seed = newSeed }



-- VIEW


view : Model -> Svg Never
view (Model model) =
    let
        widthStr =
            String.fromInt model.viewport.width

        heighStr =
            String.fromInt model.viewport.height

        viewBoxStr =
            String.join " "
                [ "0"
                , "0"
                , widthStr
                , heighStr
                ]
    in
    Svg.svg
        [ Svg.Attributes.width widthStr
        , Svg.Attributes.height heighStr
        , Svg.Attributes.viewBox viewBoxStr
        , Svg.Attributes.style "background-color: #f5f5f5"
        ]
        ([ Svg.g []
            (Collection.items model.quads
                |> List.map (Quad.view model.settings.separation)
            )
         , Svg.g []
            (Batcher.currentBatch model.quadBatcher
                |> Array.toList
                |> List.map (Quad.view model.settings.separation)
            )
         ]
            ++ (Batcher.fullBatches model.quadBatcher
                    |> Array.toList
                    |> List.indexedMap
                        (\idx batch ->
                            Svg.Lazy.lazy
                                (\_ ->
                                    Svg.g []
                                        (batch
                                            |> Array.toList
                                            |> List.map (Quad.view model.settings.separation)
                                        )
                                )
                                idx
                        )
               )
        )
