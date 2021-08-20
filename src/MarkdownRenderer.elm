module MarkdownRenderer exposing (TableOfContents, renderer, view)

import Browser.Dom exposing (Element)
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Lazy
import Element.Region
import FeatherIcons
import Html exposing (Attribute, Html, details)
import Html.Attributes exposing (property)
import Html.Keyed
import Html.Lazy
import Json.Encode as Encode exposing (Value)
import Markdown.Block
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer
import Oembed
import SyntaxHighlight
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
    Markdown.Block.extractInlineText list


gatherHeadings : List Markdown.Block.Block -> List ( Int, List Markdown.Block.Inline )
gatherHeadings blocks =
    List.filterMap
        (\block ->
            case block of
                Markdown.Block.Heading level content ->
                    Just ( Markdown.Block.headingLevelToInt level, content )

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
            case Markdown.Renderer.render renderer okAst of
                Ok rendered ->
                    Ok ( buildToc okAst, rendered )

                Err errors ->
                    Err errors

        Err error ->
            Err (error |> List.map Markdown.Parser.deadEndToString |> String.join "\n")


renderer : Markdown.Renderer.Renderer (ViewSettings -> Element msg)
renderer =
    { heading = heading
    , text = \content viewSettings -> Element.text content
    , strong = strong
    , emphasis = emphasis
    , strikethrough = strikethrough
    , codeSpan = codeSpan
    , link = link
    , image = image
    , unorderedList = unorderedList
    , orderedList = \_ _ _ -> Element.text "TODO"
    , codeBlock = codeBlock
    , html = customHtml
    , paragraph = paragraph
    , thematicBreak = \_ -> Element.text "TODO"
    , table = \_ _ -> Element.text "TODO"
    , tableHeader = \_ _ -> Element.text "TODO"
    , tableBody = \_ _ -> Element.text "TODO"
    , tableRow = \_ _ -> Element.text "TODO"
    , tableCell = \_ _ _ -> Element.text "TODO"
    , tableHeaderCell = \_ _ _ -> Element.text "TODO"
    , blockQuote = \_ _ -> Element.text "TODO"
    , hardLineBreak = \_ -> Element.text "TODO"
    }


strong : List (ViewSettings -> Element msg) -> ViewSettings -> Element msg
strong children viewSettings =
    Element.wrappedRow [ Font.bold ] (List.map (\child -> child viewSettings) children)


emphasis : List (ViewSettings -> Element msg) -> ViewSettings -> Element msg
emphasis children viewSettings =
    Element.wrappedRow [ Font.italic ] (List.map (\child -> child viewSettings) children)


strikethrough : List (ViewSettings -> Element msg) -> ViewSettings -> Element msg
strikethrough children viewSettings =
    Element.wrappedRow [ Font.strike ] (List.map (\child -> child viewSettings) children)


link : { title : Maybe String, destination : String } -> List (ViewSettings -> Element msg) -> ViewSettings -> Element msg
link { title, destination } children viewSettings =
    Element.newTabLink
        [ Element.htmlAttribute (Html.Attributes.style "display" "inline-flex")
        ]
        { url = destination
        , label =
            Element.paragraph [ Font.underline ]
                (List.map (\v -> v viewSettings) children)
        }


image : { alt : String, src : String, title : Maybe String } -> ViewSettings -> Element msg
image { alt, src } viewSettings =
    Element.image [ Element.width Element.fill ] { src = src, description = alt }


paragraph : List (ViewSettings -> Element msg) -> ViewSettings -> Element msg
paragraph children viewSettings =
    Element.paragraph [ Element.spacing viewSettings.spacing.sm ] (List.map (\child -> child viewSettings) children)


customHtml : Markdown.Html.Renderer (List (ViewSettings -> Element msg) -> ViewSettings -> Element msg)
customHtml =
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
                            , Html.Attributes.property "appname" (Encode.string appName)
                            , Html.Attributes.property "flags" (Encode.string flags)
                            ]
                            []
            )
            |> Markdown.Html.withAttribute "src"
            |> Markdown.Html.withAttribute "appname"
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


rawTextToId rawText =
    rawText
        |> String.toLower
        |> String.replace " " ""


heading : { level : Markdown.Block.HeadingLevel, rawText : String, children : List (ViewSettings -> Element msg) } -> ViewSettings -> Element msg
heading { level, rawText, children } viewSettings =
    Element.paragraph
        [ Font.size
            (case level of
                Markdown.Block.H1 ->
                    viewSettings.font.size.xl

                Markdown.Block.H2 ->
                    viewSettings.font.size.lg

                _ ->
                    viewSettings.font.size.md
            )
        , Font.bold
        , Element.Region.heading (Markdown.Block.headingLevelToInt level)
        , Element.htmlAttribute
            (Html.Attributes.attribute "name" (rawTextToId rawText))
        , Element.htmlAttribute
            (Html.Attributes.id (rawTextToId rawText))
        ]
    <|
        List.map (\child -> child viewSettings) children


unorderedList : List (Markdown.Block.ListItem (ViewSettings -> Element msg)) -> ViewSettings -> Element msg
unorderedList itemViews viewSettings =
    Element.column [ Element.spacing viewSettings.spacing.sm ]
        (itemViews
            |> List.map
                (\(Markdown.Block.ListItem task itemBlocks) ->
                    Element.wrappedRow [ Element.spacing viewSettings.spacing.xs ]
                        [ Element.el
                            [ Element.alignTop ]
                            (Element.text "•")
                        , paragraph itemBlocks viewSettings
                        ]
                )
        )


codeSpan : String -> ViewSettings -> Element msg
codeSpan snippet viewSettings =
    Element.el
        [ Background.color viewSettings.color.mainBackground
        , Border.rounded 2
        , Element.padding viewSettings.spacing.xs
        , Font.family [ Font.monospace ]
        ]
        (Element.text snippet)


codeBlock : { body : String, language : Maybe String } -> ViewSettings -> Element msg
codeBlock details viewSettings =
    -- Html.node "code-editor"
    --     ([ editorValue details.body
    --      , Html.Attributes.style "overflow" "scroll"
    --      ]
    --         ++ (Maybe.map
    --                 (\lang ->
    --                     [ languageAttr lang ]
    --                 )
    --                 details.language
    --                 |> Maybe.withDefault []
    --            )
    --     )
    --     []
    let
        langRenderer =
            case details.language of
                Nothing ->
                    SyntaxHighlight.noLang

                Just "elm" ->
                    SyntaxHighlight.elm

                Just "html" ->
                    SyntaxHighlight.xml

                _ ->
                    SyntaxHighlight.noLang
    in
    langRenderer (String.trimRight details.body)
        |> Result.map (SyntaxHighlight.toBlockHtml (Just 1))
        |> Result.map
            (\html ->
                html
                    |> Element.html
                    |> Element.el
                        [ Element.width Element.fill ]
            )
        |> Result.withDefault (Element.text "ERROR IN CODE SNIPPET")


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
