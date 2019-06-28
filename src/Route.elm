module Route exposing (Route(..), parseUrl, toUrlString)

import Url exposing (Url)
import Url.Builder
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Home
    | Post String
    | QuadDivision
    | NotFound


routeParser : Parser (Route -> a) a
routeParser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map Post (Parser.s "post" </> Parser.string)
        , Parser.map QuadDivision (Parser.s "quad-division")
        , Parser.map NotFound (Parser.s "not-found")
        ]


toUrlString : Route -> String
toUrlString route =
    case route of
        Home ->
            Url.Builder.absolute [] []

        Post id ->
            Url.Builder.absolute [ "post", id ] []

        QuadDivision ->
            Url.Builder.absolute [ "quad-division" ] []

        NotFound ->
            Url.Builder.absolute [ "not-found" ] []


parseUrl : Url -> Route
parseUrl url =
    Parser.parse routeParser url
        |> Maybe.withDefault NotFound
