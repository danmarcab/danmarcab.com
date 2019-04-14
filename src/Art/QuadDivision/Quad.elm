module Art.QuadDivision.Quad exposing (Quad, canSubdivide, initialQuadGenerator, subdivide, view)

import Axis2d
import Direction2d
import Geometry.Svg as GeoSvg
import LineSegment2d
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


canSubdivide : Float -> Quad -> Bool
canSubdivide separation { polygon } =
    case Polygon2d.outerLoop polygon of
        [ p1, p2, p3, p4 ] ->
            let
                bigEnough =
                    Polygon2d.area polygon
                        > (500 * separation * separation)

                longEnough pp1 pp2 =
                    (Vector2d.from pp1 pp2
                        |> Vector2d.length
                    )
                        > (20 * separation)

                canCutHorizontal =
                    longEnough p2 p3 && longEnough p4 p1

                canCutVertical =
                    longEnough p1 p2 && longEnough p3 p4
            in
            bigEnough && (canCutHorizontal || canCutVertical)

        _ ->
            False


subdivide : Random.Seed -> Float -> Quad -> ( Random.Seed, List Quad )
subdivide seed separation ({ polygon, prevDivide } as quad) =
    let
        bigEnough =
            Polygon2d.area polygon
                > (100 * separation * separation)

        longEnough p1 p2 =
            (Vector2d.from p1 p2
                |> Vector2d.length
            )
                > (10 * separation)
    in
    case Polygon2d.outerLoop polygon of
        [ p1, p2, p3, p4 ] ->
            let
                canCutHorizontal =
                    longEnough p2 p3 && longEnough p4 p1

                canCutVertical =
                    longEnough p1 p2 && longEnough p3 p4
            in
            case ( bigEnough, canCutHorizontal, canCutVertical ) of
                ( False, _, _ ) ->
                    ( seed, [ quad ] )

                ( True, True, True ) ->
                    let
                        ( divideType, newSeed1 ) =
                            Random.step (divideTypeGenerator prevDivide) seed
                    in
                    case divideType of
                        Horizontal ->
                            splitHorizontal newSeed1 separation quad

                        Vertical ->
                            splitVertical newSeed1 separation quad

                ( True, True, False ) ->
                    splitHorizontal seed separation quad

                ( True, False, True ) ->
                    splitVertical seed separation quad

                ( True, False, False ) ->
                    ( seed, [ quad ] )

        _ ->
            ( seed, [ quad ] )


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


view : Quad -> Svg Never
view { polygon, color } =
    GeoSvg.polygon2d
        [ Svg.Attributes.fill color
        ]
        polygon


splitHorizontal : Random.Seed -> Float -> Quad -> ( Random.Seed, List Quad )
splitHorizontal seed separation { polygon, color } =
    case Polygon2d.outerLoop polygon of
        [ p1, p2, p3, p4 ] ->
            let
                ( newSeed1, cutOff1 ) =
                    cutOff seed p2 p3

                ( newSeed2, cutOff2 ) =
                    cutOff newSeed1 p4 p1

                ( ( cutOff1a, cutOff1b ), ( cutOff2a, cutOff2b ) ) =
                    separate separation p1 p2 cutOff1 cutOff2

                ( ( color1, color2 ), newSeed3 ) =
                    Random.step (Random.pair colorGenerator colorGenerator) newSeed2
            in
            ( newSeed3
            , [ { polygon = Polygon2d.singleLoop [ p1, p2, cutOff1a, cutOff2b ]
                , color = color1
                , prevDivide = Horizontal
                }
              , { polygon = Polygon2d.singleLoop [ cutOff2a, cutOff1b, p3, p4 ]
                , color = color2
                , prevDivide = Horizontal
                }
              ]
            )

        _ ->
            ( seed, [] )


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


splitVertical : Random.Seed -> Float -> Quad -> ( Random.Seed, List Quad )
splitVertical seed separation { polygon, color } =
    case Polygon2d.outerLoop polygon of
        [ p1, p2, p3, p4 ] ->
            let
                ( newSeed1, cutOff1 ) =
                    cutOff seed p1 p2

                ( newSeed2, cutOff2 ) =
                    cutOff newSeed1 p3 p4

                ( ( cutOff1a, cutOff1b ), ( cutOff2a, cutOff2b ) ) =
                    separate separation p4 p1 cutOff1 cutOff2
            in
            ( newSeed2
            , [ { polygon = Polygon2d.singleLoop [ p1, cutOff1a, cutOff2b, p4 ]
                , color = color
                , prevDivide = Vertical
                }
              , { polygon = Polygon2d.singleLoop [ cutOff1b, p2, p3, cutOff2a ]
                , color = color
                , prevDivide = Vertical
                }
              ]
            )

        _ ->
            ( seed, [] )


separate : Float -> Point2d -> Point2d -> Point2d -> Point2d -> ( ( Point2d, Point2d ), ( Point2d, Point2d ) )
separate separation p1 p2 c1 c2 =
    let
        default =
            ( ( c1, c1 ), ( c2, c2 ) )
    in
    Maybe.andThen
        (\cutDir ->
            let
                pushVect =
                    Direction2d.perpendicularTo cutDir
                        |> Direction2d.toVector
                        |> Vector2d.scaleBy separation

                pullVect =
                    Vector2d.reverse pushVect

                cutAxis =
                    Axis2d.withDirection cutDir c1

                pushedAxis =
                    cutAxis
                        |> Axis2d.translateBy pushVect

                pulledAxis =
                    cutAxis
                        |> Axis2d.translateBy pullVect

                lineP2C1 =
                    LineSegment2d.from p2 c1
                        |> LineSegment2d.scaleAbout p2 10

                lineP1C2 =
                    LineSegment2d.from p1 c2
                        |> LineSegment2d.scaleAbout p1 10
            in
            Maybe.map4
                (\c1a c1b c2a c2b ->
                    ( ( c1a, c1b ), ( c2a, c2b ) )
                )
                (LineSegment2d.intersectionWithAxis pushedAxis lineP2C1)
                (LineSegment2d.intersectionWithAxis pulledAxis lineP2C1)
                (LineSegment2d.intersectionWithAxis pulledAxis lineP1C2)
                (LineSegment2d.intersectionWithAxis pushedAxis lineP1C2)
        )
        (Direction2d.from c1 c2)
        |> Maybe.withDefault default



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
