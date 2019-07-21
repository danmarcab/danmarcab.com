module Data.Post exposing
    ( Post
    , Tag
    , fromFileAndMarkup
    )

import Config exposing (Config)
import Element exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Html
import Iso8601
import Mark
import Mark.Error
import Time


type alias Post =
    { id : String
    , title : String
    , abstract : String
    , publishedDate : Time.Posix
    , published : Bool
    , tags : List Tag
    , content : Config -> Element Never
    }


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
            , publishedDate = meta.publishedDate
            , published = meta.published
            , tags = meta.tags
            , content =
                \config ->
                    Element.textColumn
                        [ Font.family
                            [ Font.typeface "Verdana"
                            , Font.typeface "Arial"
                            , Font.sansSerif
                            ]
                        , Element.width Element.fill
                        ]
                        (List.map (\b -> b config)
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


type alias Metadata =
    { title : String
    , abstract : String
    , publishedDate : Time.Posix
    , published : Bool
    , tags : List String
    }


metadata : Mark.Block Metadata
metadata =
    Mark.record "Post"
        Metadata
        |> Mark.field "title" Mark.string
        |> Mark.field "abstract" Mark.string
        |> Mark.field "publishedDate" date
        |> Mark.field "published" Mark.bool
        |> Mark.field "tags" (Mark.map (String.split ", ") Mark.string)
        |> Mark.toBlock


date : Mark.Block Time.Posix
date =
    Mark.verify
        (\str ->
            str
                |> Iso8601.toTime
                |> Result.mapError
                    (\_ ->
                        { title = "Bad Date"
                        , message =
                            [ "I was trying to parse a date, but this format looks off.\n\n"
                            , "Dates should be in ISO 8601 format:\n\n"
                            , "YYYY-MM-DDTHH:mm:ss.SSSZ"
                            ]
                        }
                    )
        )
        Mark.string


text : Mark.Block (List (Config -> Element msg))
text =
    Mark.textWith
        { view = viewText
        , replacements = Mark.commonReplacements
        , inlines =
            [ Mark.annotation "link"
                (\texts url config ->
                    let
                        linkText =
                            texts
                                |> List.map Tuple.second
                                |> String.join " "
                    in
                    Element.link [ Font.color config.colors.primary ]
                        { url = url
                        , label = viewText { bold = False, strike = False, italic = False } linkText config
                        }
                )
                |> Mark.field "url" Mark.string
            ]
        }


viewText : Mark.Styles -> String -> Config -> Element msg
viewText styles string _ =
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


header : Mark.Block (Config -> Element msg)
header =
    Mark.block "Header"
        (\headerText _ ->
            Element.paragraph
                [ Font.size 24
                , Element.spacing 12
                , Font.bold
                , Element.paddingEach { top = 0, bottom = 20, right = 0, left = 0 }
                ]
                [ Element.text headerText ]
        )
        Mark.string


code : Mark.Block (Config -> Element msg)
code =
    Mark.block "Code"
        (\codeText config ->
            Element.el
                [ Element.paddingEach { top = 0, bottom = 20, right = 0, left = 0 }
                , Element.width Element.fill
                ]
            <|
                Element.el
                    [ Background.color config.colors.mainBackground
                    , Element.paddingXY 20 0
                    , Element.width Element.fill
                    ]
                <|
                    Element.html <|
                        Html.pre [] [ Html.text codeText ]
        )
        Mark.string


image : Mark.Block (Config -> Element msg)
image =
    Mark.record "Image"
        (\src description _ ->
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
