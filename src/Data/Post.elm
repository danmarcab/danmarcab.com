module Data.Post exposing
    ( Post
    , Tag
    , dateSorter
    , fromFileAndMarkup
    )

import Element exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Html
import Mark
import Mark.Error
import Style.Color as Color


type alias Date =
    ( Int, Int, Int )


type alias Post =
    { id : String
    , title : String
    , abstract : String
    , publishedDate : Date
    , published : Bool
    , tags : List Tag
    , content : Color.Scheme -> Element Never
    }


type Content
    = Text String


type alias Tag =
    String


type alias FileName =
    String


type alias Markup =
    String


fromFileAndMarkup : FileName -> Markup -> Mark.Outcome (List Mark.Error.Error) (Mark.Partial Post) Post
fromFileAndMarkup file markup =
    Mark.compile (document file) markup


document : String -> Mark.Document Post
document id =
    Mark.documentWith
        (\meta contentBlocks ->
            { id = id
            , title = meta.title
            , abstract = meta.abstract
            , publishedDate = ( 2019, 3, 9 )
            , published = meta.published
            , tags = meta.tags
            , content =
                \colorScheme ->
                    Element.textColumn
                        [ Font.family
                            [ Font.typeface "Verdana"
                            , Font.typeface "Arial"
                            , Font.sansSerif
                            ]
                        , Element.width Element.fill
                        ]
                        (List.map (\b -> b colorScheme)
                            contentBlocks
                        )
            }
        )
        { metadata = metadata
        , body =
            Mark.manyOf
                [ header
                , image
                , code
                , Mark.map
                    (\ts cs ->
                        Element.paragraph
                            [ Font.size 20
                            , Element.spacing 12
                            , Element.paddingEach { top = 0, bottom = 40, right = 0, left = 0 }
                            ]
                            (List.map (\t -> t cs) ts)
                    )
                    text
                ]
        }


metadata =
    Mark.record "Post"
        (\title abstract published tags ->
            { title = title
            , abstract = abstract
            , published = published
            , tags = tags
            }
        )
        |> Mark.field "title" Mark.string
        |> Mark.field "abstract" Mark.string
        |> Mark.field "published" Mark.bool
        |> Mark.field "tags" (Mark.map (String.split ", ") Mark.string)
        |> Mark.toBlock


text : Mark.Block (List (Color.Scheme -> Element msg))
text =
    Mark.textWith
        { view = viewText
        , replacements = Mark.commonReplacements
        , inlines =
            [ Mark.annotation "link"
                (\texts url colorScheme ->
                    let
                        linkText =
                            texts
                                |> List.map Tuple.second
                                |> String.join " "
                    in
                    Element.link [ Font.color (Color.primary colorScheme) ]
                        { url = url
                        , label = viewText { bold = False, strike = False, italic = False } linkText colorScheme
                        }
                )
                |> Mark.field "url" Mark.string
            ]
        }


viewText : Mark.Styles -> String -> Color.Scheme -> Element msg
viewText styles string colorScheme =
    let
        attrs =
            [ ( styles.bold, Font.bold ), ( styles.italic, Font.italic ), ( styles.strike, Font.strike ) ]
                |> List.filter Tuple.first
                |> List.map Tuple.second
    in
    case attrs of
        [] ->
            Element.text string

        _ ->
            Element.el attrs (Element.text string)


header : Mark.Block (Color.Scheme -> Element msg)
header =
    Mark.block "Header"
        (\headerText colorScheme ->
            Element.paragraph
                [ Font.size 24
                , Element.spacing 12
                , Font.bold
                , Element.paddingEach { top = 0, bottom = 20, right = 0, left = 0 }
                ]
                [ Element.text headerText ]
        )
        Mark.string


code : Mark.Block (Color.Scheme -> Element msg)
code =
    Mark.block "Code"
        (\codeText colorScheme ->
            Element.el
                [ Element.paddingEach { top = 0, bottom = 20, right = 0, left = 0 }
                , Element.width Element.fill
                ]
            <|
                Element.el
                    [ Background.color (Color.background colorScheme)
                    , Element.paddingXY 20 0
                    , Element.width Element.fill
                    ]
                <|
                    Element.html <|
                        Html.pre [] [ Html.text codeText ]
        )
        Mark.string


image : Mark.Block (Color.Scheme -> Element msg)
image =
    Mark.record "Image"
        (\src description colorScheme ->
            Element.column
                [ Element.width Element.fill
                , Element.spacing 10
                , Element.paddingEach { top = 0, bottom = 30, right = 0, left = 0 }
                ]
                [ Element.image
                    [ Element.centerX
                    ]
                    { src = src, description = description }
                , Element.el [ Element.centerX ] <| Element.text description
                ]
        )
        |> Mark.field "src" Mark.string
        |> Mark.field "description" Mark.string
        |> Mark.toBlock


dateSorter : Post -> Post -> Order
dateSorter post1 post2 =
    compare post1.publishedDate post2.publishedDate
