module Data.Post exposing (Content, Metadata, contentDataSource, metadataDataSource, postsDataSource)

import Browser.Dom
import DataSource exposing (DataSource)
import DataSource.File
import DataSource.Glob as Glob
import Date exposing (Date)
import Element exposing (Element)
import Markdown.Parser
import Markdown.Renderer
import MarkdownRenderer
import OptimizedDecoder exposing (Decoder)
import OptimizedDecoder.Pipeline as OptimizedDecoder
import ViewSettings exposing (ViewSettings)


postsPath =
    "content/posts/"


postsDataSource : DataSource (List Metadata)
postsDataSource =
    Glob.succeed
        (\filePath slug ->
            { filePath = filePath
            , slug = slug
            }
        )
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal postsPath)
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toDataSource
        |> DataSource.map
            (\posts ->
                List.map
                    (\post ->
                        DataSource.File.onlyFrontmatter (metadataDecoder post.slug) post.filePath
                    )
                    posts
            )
        |> DataSource.resolve


type alias Metadata =
    { slug : String
    , title : String
    , description : String
    , published : Date
    , image : String
    , draft : Bool
    }


type alias Content msg =
    ViewSettings -> Element msg


contentDataSource : String -> DataSource (Content msg)
contentDataSource slug =
    DataSource.File.bodyWithoutFrontmatter (postsPath ++ slug ++ ".md")
        |> DataSource.andThen
            (\markdown ->
                markdownToView markdown
                    |> Result.map
                        (\contents viewSettings ->
                            Element.column
                                [ Element.spacing viewSettings.spacing.lg
                                , Element.width Element.fill
                                ]
                                (List.map (\v -> v viewSettings) contents)
                        )
                    |> DataSource.fromResult
            )


metadataDataSource : String -> DataSource Metadata
metadataDataSource slug =
    DataSource.File.onlyFrontmatter (metadataDecoder slug) (postsPath ++ slug ++ ".md")


metadataDecoder : String -> Decoder Metadata
metadataDecoder slug =
    OptimizedDecoder.decode (Metadata slug)
        |> OptimizedDecoder.required "title" OptimizedDecoder.string
        |> OptimizedDecoder.required "description" OptimizedDecoder.string
        |> OptimizedDecoder.required "published" dateDecoder
        |> OptimizedDecoder.required "image" OptimizedDecoder.string
        |> OptimizedDecoder.optional "draft" OptimizedDecoder.bool False


dateDecoder : Decoder Date
dateDecoder =
    OptimizedDecoder.string
        |> OptimizedDecoder.andThen
            (\isoString ->
                case Date.fromIsoString isoString of
                    Ok date ->
                        OptimizedDecoder.succeed date

                    Err error ->
                        OptimizedDecoder.fail error
            )


markdownToView :
    String
    -> Result String (List (ViewSettings -> Element msg))
markdownToView markdownString =
    markdownString
        |> Markdown.Parser.parse
        |> Result.mapError (\_ -> "Markdown error.")
        |> Result.andThen
            (\blocks ->
                Markdown.Renderer.render
                    MarkdownRenderer.renderer
                    blocks
            )
