module Widget.SimpleTree exposing (fromString, highlightFromString, view)

import Element exposing (Element)
import Html exposing (Html)
import Parser exposing ((|.), (|=), Parser)
import Svg exposing (Svg)
import Svg.Attributes as SA
import TreeDiagram exposing (BoundingBox, Position, Tree)
import ViewSettings exposing (ViewSettings)


view :
    ViewSettings
    ->
        { highlightEdgesTo : List ( Int, Color )
        , highlightNodes : List ( Int, Color )
        }
    -> Tree Int
    -> Element msg
view viewSettings { highlightEdgesTo, highlightNodes } tree =
    let
        one =
            Element.el
                [ Element.centerX
                ]
            <|
                Element.html <|
                    TreeDiagram.draw
                        { nodeRadius = 30
                        , subtreeDist = 100
                        , levelHeight = 100
                        , drawNode = drawNode highlightNodes
                        , drawEdge = drawEdge highlightEdgesTo
                        , compose = compose
                        }
                        tree
    in
    Element.el [ Element.width Element.fill, Element.centerX ] one


compose : BoundingBox -> List (Svg msg) -> Html msg
compose bb stuff =
    let
        vBox =
            String.fromInt bb.fromX
                ++ " "
                ++ String.fromInt bb.fromY
                ++ " "
                ++ String.fromInt (bb.toX - bb.fromX)
                ++ " "
                ++ String.fromInt (bb.toY - bb.fromY)
    in
    Svg.svg
        [ SA.viewBox vBox
        , SA.width <| String.fromInt (bb.toX - bb.fromX)
        , SA.style "max-width: 100%"
        ]
        [ Svg.g [] stuff ]


drawNode : List ( Int, Color ) -> Position -> Int -> Svg msg
drawNode highlight pos n =
    Svg.g
        [ SA.transform <|
            "translate("
                ++ String.fromInt pos.x
                ++ " "
                ++ String.fromInt pos.y
                ++ ")"
        ]
        [ Svg.circle
            [ SA.r "27"
            , SA.stroke (getColorFor highlight n Black)
            , SA.strokeWidth "3"
            , SA.fill "white"
            , SA.cx "0"
            , SA.cy "0"
            ]
            []
        , Svg.text_
            [ SA.textAnchor "middle"
            , SA.dominantBaseline "central"
            , SA.fill "black"
            , SA.fontSize "25"
            , SA.fontFamily "sans-serif"
            ]
            [ Svg.text <| String.fromInt n ]
        ]


drawEdge : List ( Int, Color ) -> ( Position, Int ) -> ( Position, Int ) -> Svg msg
drawEdge highlightTo ( from, _ ) ( to, toVal ) =
    Svg.line
        [ SA.x1 (String.fromInt from.x)
        , SA.y1 (String.fromInt from.y)
        , SA.x2 (String.fromInt to.x)
        , SA.y2 (String.fromInt to.y)
        , SA.stroke (getColorFor highlightTo toVal Black)
        , SA.strokeWidth "3"
        ]
        []


getColorFor : List ( Int, Color ) -> Int -> Color -> String
getColorFor list num defaultColor =
    case list of
        ( numToHighlight, colorToHighlight ) :: more ->
            if num == numToHighlight then
                colorToString colorToHighlight

            else
                getColorFor more num defaultColor

        [] ->
            colorToString defaultColor


type Color
    = Black
    | White
    | Red
    | Green
    | Blue
    | Magenta
    | Cyan
    | Yellow
    | Orange


colorToString : Color -> String
colorToString color =
    case color of
        Black ->
            "black"

        White ->
            "white"

        Red ->
            "red"

        Green ->
            "green"

        Blue ->
            "blue"

        Magenta ->
            "magenta"

        Cyan ->
            "cyan"

        Yellow ->
            "yellow"

        Orange ->
            "orange"



-- PARSER


highlightFromString : String -> Maybe (List ( Int, Color ))
highlightFromString string =
    Parser.run (listParser highlightParser) string
        |> Result.toMaybe


highlightParser : Parser ( Int, Color )
highlightParser =
    Parser.succeed Tuple.pair
        |= myInt
        |. Parser.token ":"
        |= colorParser


colorParser : Parser Color
colorParser =
    Parser.oneOf
        [ Parser.succeed Black
            |. Parser.keyword "k"
        , Parser.succeed White
            |. Parser.keyword "w"
        , Parser.succeed Red
            |. Parser.keyword "r"
        , Parser.succeed Green
            |. Parser.keyword "g"
        , Parser.succeed Blue
            |. Parser.keyword "b"
        , Parser.succeed Magenta
            |. Parser.keyword "m"
        , Parser.succeed Cyan
            |. Parser.keyword "c"
        , Parser.succeed Yellow
            |. Parser.keyword "y"
        , Parser.succeed Orange
            |. Parser.keyword "o"
        ]


fromString : String -> Maybe (Tree Int)
fromString string =
    Parser.run preorderParser string
        |> Result.toMaybe
        |> Maybe.andThen fromPreorder


preorderParser : Parser (List ParsedNode)
preorderParser =
    listParser nodeParser


listParser : Parser a -> Parser (List a)
listParser parser =
    Parser.loop [] <|
        \revEls ->
            Parser.oneOf
                [ Parser.succeed (\el -> Parser.Loop (el :: revEls))
                    |= parser
                    |. Parser.spaces
                , Parser.succeed ()
                    |> Parser.map (\_ -> Parser.Done (List.reverse revEls))
                ]


type ParsedNode
    = ParsedInt Int
    | ParsedLeaf


fromPreorder : List ParsedNode -> Maybe (Tree Int)
fromPreorder nodes =
    let
        consume someNodes =
            case someNodes of
                [] ->
                    ( Nothing, [] )

                node :: more ->
                    case node of
                        ParsedLeaf ->
                            ( Nothing, more )

                        ParsedInt int ->
                            let
                                ( leftSubTree, rem ) =
                                    consume more

                                ( rightSubTree, fin ) =
                                    consume rem
                            in
                            ( Just <|
                                TreeDiagram.node int
                                    (leftSubTree |> Maybe.withDefault TreeDiagram.empty)
                                    (rightSubTree |> Maybe.withDefault TreeDiagram.empty)
                            , fin
                            )
    in
    case consume nodes of
        ( tree, [] ) ->
            tree

        _ ->
            Nothing


nodeParser : Parser ParsedNode
nodeParser =
    Parser.oneOf
        [ Parser.succeed ParsedLeaf
            |. Parser.keyword "l"
        , Parser.map ParsedInt myInt
        ]


myInt : Parser Int
myInt =
    Parser.oneOf
        [ Parser.succeed negate
            |. Parser.symbol "-"
            |= Parser.int
        , Parser.int
        ]
