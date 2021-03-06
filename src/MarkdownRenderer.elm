module MarkdownRenderer exposing (TableOfContents, view)

import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Lazy
import Element.Region
import FeatherIcons
import Html exposing (Attribute, Html)
import Html.Attributes exposing (property)
import Html.Keyed
import Html.Lazy
import Json.Encode as Encode exposing (Value)
import Markdown.Block
import Markdown.Html
import Markdown.Parser
import Oembed
import TreeDiagram
import ViewSettings exposing (ViewSettings)
import Widget.Figure as Figure
import Widget.Icon as Icon
import Widget.SimpleTree as SimpleTree


buildToc : List Markdown.Block.Block -> TableOfContents
buildToc blocks =
    let
        headings =
            gatherHeadings blocks
    in
    headings
        |> List.map Tuple.second
        |> List.map
            (\styledList ->
                { anchorId = styledToString styledList
                , name = styledToString styledList |> rawTextToId
                , level = 1
                }
            )


styledToString : List Markdown.Block.Inline -> String
styledToString list =
    List.map .string list
        |> String.join "-"


gatherHeadings : List Markdown.Block.Block -> List ( Int, List Markdown.Block.Inline )
gatherHeadings blocks =
    List.filterMap
        (\block ->
            case block of
                Markdown.Block.Heading level content ->
                    Just ( level, content )

                _ ->
                    Nothing
        )
        blocks


type alias TableOfContents =
    List { anchorId : String, name : String, level : Int }


view : String -> Result String ( TableOfContents, List (ViewSettings -> Element msg) )
view markdown =
    case
        markdown
            |> Markdown.Parser.parse
    of
        Ok okAst ->
            case Markdown.Parser.render renderer okAst of
                Ok rendered ->
                    Ok ( buildToc okAst, rendered )

                Err errors ->
                    Err errors

        Err error ->
            Err (error |> List.map Markdown.Parser.deadEndToString |> String.join "\n")


renderer : Markdown.Parser.Renderer (ViewSettings -> Element msg)
renderer =
    { heading = heading
    , raw =
        \contentViews viewSettings ->
            Element.paragraph
                [ Element.spacing viewSettings.spacing.sm ]
                (List.map (\v -> v viewSettings) contentViews)
    , thematicBreak = \viewSettings -> Element.none
    , plain = \content viewSettings -> Element.text content
    , bold = \content viewSettings -> Element.el [ Font.bold ] (Element.text content)
    , italic = \content viewSettings -> Element.el [ Font.italic ] (Element.text content)
    , code = code
    , link =
        \link linkViews ->
            Ok <|
                \viewSettings ->
                    Element.newTabLink
                        [ Element.htmlAttribute (Html.Attributes.style "display" "inline-flex")
                        ]
                        { url = link.destination
                        , label =
                            Element.paragraph [ Font.underline ]
                                (List.map (\v -> v viewSettings) linkViews)
                        }
    , image =
        \image body ->
            Ok <|
                \viewSettings ->
                    Element.image [ Element.width Element.fill ] { src = image.src, description = body }
    , list = listView
    , codeBlock = codeBlock
    , html =
        Markdown.Html.oneOf
            [ Markdown.Html.tag "Oembed"
                (\url children viewSettings ->
                    Oembed.view [] Nothing url
                        |> Maybe.map Element.html
                        |> Maybe.withDefault Element.none
                        |> Element.el [ Element.centerX ]
                )
                |> Markdown.Html.withAttribute "url"
            , Markdown.Html.tag "elm-app"
                (\src appName flags children viewSettings ->
                    Element.el
                        [ Element.width Element.fill
                        , Background.color viewSettings.color.mainBackground
                        ]
                    <|
                        Element.html <|
                            Html.node "elm-app"
                                [ Html.Attributes.property "src" (Encode.string src)
                                , Html.Attributes.property "appName" (Encode.string appName)
                                , Html.Attributes.property "flags" (Encode.string flags)
                                ]
                                []
                )
                |> Markdown.Html.withAttribute "src"
                |> Markdown.Html.withAttribute "appName"
                |> Markdown.Html.withAttribute "flags"
            , Markdown.Html.tag "custom-figure"
                (\description children viewSettings ->
                    let
                        renderedChildren =
                            Element.row
                                [ Element.spaceEvenly
                                , Element.spacing viewSettings.spacing.md
                                , Element.width Element.fill
                                ]
                            <|
                                List.map (\child -> child viewSettings) children
                    in
                    Figure.view viewSettings description renderedChildren
                )
                |> Markdown.Html.withAttribute "description"
            , Markdown.Html.tag "simple-tree"
                (\preorder nodes edgesTo children viewSettings ->
                    SimpleTree.fromString preorder
                        |> Maybe.map
                            (\tree ->
                                SimpleTree.view viewSettings
                                    { highlightEdgesTo =
                                        edgesTo
                                            |> Maybe.andThen SimpleTree.highlightFromString
                                            |> Maybe.withDefault []
                                    , highlightNodes =
                                        nodes
                                            |> Maybe.andThen SimpleTree.highlightFromString
                                            |> Maybe.withDefault []
                                    }
                                    tree
                            )
                        |> Maybe.withDefault (Element.text "Invalid Tree")
                )
                |> Markdown.Html.withAttribute "preorder"
                |> Markdown.Html.withOptionalAttribute "highlight-nodes"
                |> Markdown.Html.withOptionalAttribute "highlight-edges-to"
            ]
    }


rawTextToId rawText =
    rawText
        |> String.toLower
        |> String.replace " " ""


heading : { level : Int, rawText : String, children : List (ViewSettings -> Element msg) } -> ViewSettings -> Element msg
heading { level, rawText, children } viewSettings =
    Element.paragraph
        [ Font.size
            (case level of
                1 ->
                    viewSettings.font.size.xl

                2 ->
                    viewSettings.font.size.lg

                _ ->
                    viewSettings.font.size.md
            )
        , Font.bold
        , Element.Region.heading level
        , Element.htmlAttribute
            (Html.Attributes.attribute "name" (rawTextToId rawText))
        , Element.htmlAttribute
            (Html.Attributes.id (rawTextToId rawText))
        ]
    <|
        List.map (\child -> child viewSettings) children


listView : List (ViewSettings -> Element msg) -> ViewSettings -> Element msg
listView itemViews viewSettings =
    Element.column [ Element.spacing viewSettings.spacing.sm ]
        (itemViews
            |> List.map
                (\itemBlocks ->
                    Element.wrappedRow [ Element.spacing viewSettings.spacing.xs ]
                        [ Element.el
                            [ Element.alignTop ]
                            (Element.text "•")
                        , itemBlocks viewSettings
                        ]
                )
        )


code : String -> ViewSettings -> Element msg
code snippet viewSettings =
    Element.el
        [ Background.color viewSettings.color.mainBackground
        , Border.rounded 2
        , Element.padding viewSettings.spacing.xs
        , Font.family [ Font.monospace ]
        ]
        (Element.text snippet)


codeBlock : { body : String, language : Maybe String } -> ViewSettings -> Element msg
codeBlock details viewSettings =
    Html.node "code-editor"
        ([ editorValue details.body
         , Html.Attributes.style "overflow" "scroll"
         ]
            ++ (Maybe.map
                    (\lang ->
                        [ languageAttr lang ]
                    )
                    details.language
                    |> Maybe.withDefault []
               )
        )
        []
        |> Element.html
        |> Element.el
            [ Element.width Element.fill ]


editorValue : String -> Attribute msg
editorValue value =
    value
        |> String.trim
        |> Encode.string
        |> property "editorValue"


languageAttr : String -> Attribute msg
languageAttr value =
    value
        |> String.trim
        |> Encode.string
        |> property "language"
