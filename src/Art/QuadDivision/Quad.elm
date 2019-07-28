module Art.QuadDivision.Quad exposing (Quad, canSubdivide, initialQuadGenerator, subdivide, view)

import Geometry.Svg as GeoSvg
import Point2d exposing (Point2d)
import Polygon2d exposing (Polygon2d)
import Random
import Svg exposing (Svg)
import Svg.Attributes
import Vector2d


type alias Quad =
    { polygon : Polygon2d
    , color : String
    , prevDivide : DivideType
    }


type DivideType
    = Vertical
    | Horizontal


canSubdivide :
    { minSide : Float, minArea : Float }
    -> Quad
    -> Bool
canSubdivide opts quad =
    case howCanSubdivide opts quad of
        NotPossible ->
            False

        CanDivideHorizontally ->
            True

        CanDivideVertically ->
            True

        CanDivideBoth ->
            True


type SubdivisionOption
    = NotPossible
    | CanDivideHorizontally
    | CanDivideVertically
    | CanDivideBoth


howCanSubdivide :
    { minSide : Float, minArea : Float }
    -> Quad
    -> SubdivisionOption
howCanSubdivide { minSide, minArea } { polygon } =
    case Polygon2d.outerLoop polygon of
        [ p1, p2, p3, p4 ] ->
            let
                bigEnough =
                    Polygon2d.area polygon
                        > minArea

                longEnough pp1 pp2 =
                    (Vector2d.from pp1 pp2
                        |> Vector2d.length
                    )
                        > minSide

                canCutHorizontal =
                    longEnough p2 p3 && longEnough p4 p1

                canCutVertical =
                    longEnough p1 p2 && longEnough p3 p4
            in
            case ( bigEnough, canCutHorizontal, canCutVertical ) of
                ( False, _, _ ) ->
                    NotPossible

                ( True, False, False ) ->
                    NotPossible

                ( True, True, False ) ->
                    CanDivideHorizontally

                ( True, False, True ) ->
                    CanDivideVertically

                ( True, True, True ) ->
                    CanDivideBoth

        _ ->
            NotPossible


subdivide :
    Random.Seed
    -> { minSide : Float, minArea : Float }
    -> Quad
    -> ( Random.Seed, List Quad )
subdivide seed opts ({ prevDivide } as quad) =
    case howCanSubdivide opts quad of
        NotPossible ->
            ( seed, [ quad ] )

        CanDivideHorizontally ->
            splitHorizontal seed quad

        CanDivideVertically ->
            splitVertical seed quad

        CanDivideBoth ->
            let
                ( divideType, newSeed1 ) =
                    Random.step (divideTypeGenerator prevDivide) seed
            in
            case divideType of
                Horizontal ->
                    splitHorizontal newSeed1 quad

                Vertical ->
                    splitVertical newSeed1 quad


splitHorizontal : Random.Seed -> Quad -> ( Random.Seed, List Quad )
splitHorizontal seed { polygon } =
    case Polygon2d.outerLoop polygon of
        [ p1, p2, p3, p4 ] ->
            split
                (\cutOff1 cutOff2 ->
                    ( Horizontal
                    , [ p1, p2, cutOff1, cutOff2 ]
                    , [ cutOff2, cutOff1, p3, p4 ]
                    )
                )
                ( p2, p3 )
                ( p4, p1 )
                seed

        _ ->
            ( seed, [] )


splitVertical : Random.Seed -> Quad -> ( Random.Seed, List Quad )
splitVertical seed { polygon } =
    case Polygon2d.outerLoop polygon of
        [ p1, p2, p3, p4 ] ->
            split
                (\cutOff1 cutOff2 ->
                    ( Vertical
                    , [ p1, cutOff1, cutOff2, p4 ]
                    , [ cutOff1, p2, p3, cutOff2 ]
                    )
                )
                ( p1, p2 )
                ( p3, p4 )
                seed

        _ ->
            ( seed, [] )


split :
    (Point2d -> Point2d -> ( DivideType, List Point2d, List Point2d ))
    -> ( Point2d, Point2d )
    -> ( Point2d, Point2d )
    -> Random.Seed
    -> ( Random.Seed, List Quad )
split f ( p1, p2 ) ( p3, p4 ) seed =
    let
        ( newSeed1, cutOff1 ) =
            cutOff seed p1 p2

        ( newSeed2, cutOff2 ) =
            cutOff newSeed1 p3 p4

        ( ( color1, color2 ), newSeed3 ) =
            Random.step (Random.pair colorGenerator colorGenerator) newSeed2

        ( divideType, quad1, quad2 ) =
            f cutOff1 cutOff2
    in
    ( newSeed3
    , [ { polygon = Polygon2d.singleLoop quad1
        , color = color1
        , prevDivide = divideType
        }
      , { polygon = Polygon2d.singleLoop quad2
        , color = color2
        , prevDivide = divideType
        }
      ]
    )


cutOff : Random.Seed -> Point2d -> Point2d -> ( Random.Seed, Point2d )
cutOff seed p1 p2 =
    let
        ( cutOffParam, newSeed ) =
            Random.step (Random.float 0.35 0.65) seed

        midPoint =
            Point2d.interpolateFrom p1 p2 cutOffParam
    in
    ( newSeed
    , midPoint
    )



-- VIEW


view : Float -> Quad -> Svg Never
view separation { polygon, color } =
    GeoSvg.polygon2d
        [ Svg.Attributes.fill color
        , Svg.Attributes.stroke "white"
        , Svg.Attributes.strokeWidth (String.fromFloat separation)
        ]
        polygon



-- RANDOM GENERATORS


initialQuadGenerator : { width : Float, height : Float } -> Random.Generator Quad
initialQuadGenerator { width, height } =
    Random.map
        (\color ->
            { polygon =
                Polygon2d.singleLoop
                    [ Point2d.fromCoordinates ( 0, 0 )
                    , Point2d.fromCoordinates ( width, 0 )
                    , Point2d.fromCoordinates ( width, height )
                    , Point2d.fromCoordinates ( 0, height )
                    ]
            , color = color
            , prevDivide = Horizontal
            }
        )
        colorGenerator


divideTypeGenerator : DivideType -> Random.Generator DivideType
divideTypeGenerator prev =
    case prev of
        Vertical ->
            Random.weighted ( 2, Horizontal ) [ ( 1, Vertical ) ]

        Horizontal ->
            Random.weighted ( 1, Horizontal ) [ ( 2, Vertical ) ]


colorGenerator : Random.Generator String
colorGenerator =
    Random.uniform "#e8b0b0"
        [ "#e8cbb0"
        , "#e6e8b0"
        , "#bee8b0"
        , "#b0e8de"
        , "#b0cae8"
        , "#b6b0e8"
        , "#ddb0e8"
        , "#e8b0d5"
        ]
