module Art.QuadDivision exposing (Model, done, initialize, subdivide, view)

import Array exposing (Array)
import Art.QuadDivision.Quad as Quad exposing (Quad)
import Browser.Dom exposing (Viewport)
import Random
import Svg exposing (Svg)
import Svg.Attributes
import Svg.Lazy
import Util.Batcher as Batcher exposing (Batcher)
import Util.Collection as Collection exposing (Collection)


type Model
    = Model
        { seed : Random.Seed
        , quads : Collection Quad
        , quadBatcher : Batcher Quad
        , separation : Float
        , viewport : Viewport
        }


initialize : Int -> Viewport -> Model
initialize initialSeed viewport =
    let
        seed =
            Random.initialSeed initialSeed

        ( initialQuad, seed2 ) =
            Random.step (Quad.initialQuadGenerator viewport.scene) seed

        separation =
            min viewport.viewport.width viewport.viewport.height / 200.0
    in
    Model
        { seed = seed2
        , quads = Collection.fromItems [ initialQuad ]
        , quadBatcher = Batcher.new 100
        , viewport = viewport
        , separation = separation
        }


done : Model -> Bool
done (Model { quads }) =
    Collection.isEmpty quads


subdivide : Model -> Model
subdivide (Model model) =
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
                    Quad.subdivide newSeed model.separation quad

                ( divisibleQuads, staticQuads ) =
                    List.partition (Quad.canSubdivide model.separation) dividedQuads
            in
            Model
                { model
                    | seed = nextSeed
                    , quads = Collection.insertMany divisibleQuads (Collection.remove indexToSubdivide model.quads)
                    , quadBatcher = Batcher.addMany staticQuads model.quadBatcher
                }

        Nothing ->
            Model { model | seed = newSeed }


view : Model -> Svg Never
view (Model model) =
    let
        viewBoxHelp nums =
            List.map String.fromFloat nums
                |> String.join " "

        viewBoxStr =
            viewBoxHelp
                [ 0
                , 0
                , model.viewport.scene.width
                , model.viewport.scene.height
                ]
    in
    Svg.svg
        [ Svg.Attributes.width "100%"
        , Svg.Attributes.height "100%"
        , Svg.Attributes.viewBox viewBoxStr
        , Svg.Attributes.style "background-color: #f5f5f5"
        ]
        ([ Svg.g []
            (Collection.items model.quads
                |> List.map Quad.view
            )
         , Svg.g []
            (Batcher.currentBatch model.quadBatcher
                |> Array.toList
                |> List.map Quad.view
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
                                            |> List.map Quad.view
                                        )
                                )
                                idx
                        )
               )
        )
