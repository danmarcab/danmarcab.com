module Route exposing (Route(..), parseUrl, toUrlString)

import Url exposing (Url)
import Url.Builder
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Home
    | QuadDivision


routeParser : Parser (Route -> a) a
routeParser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map QuadDivision (Parser.s "quad-division")
        ]


toUrlString : Route -> String
toUrlString route =
    case route of
        Home ->
            Url.Builder.absolute [] []

        QuadDivision ->
            Url.Builder.absolute [ "quad-division" ] []


parseUrl : Url -> Route
parseUrl url =
    Parser.parse routeParser url
        |> Maybe.withDefault Home
