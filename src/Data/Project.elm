module Data.Project exposing (Metadata, metadataDataSource, projectsDataSource)

import DataSource exposing (DataSource)
import DataSource.File
import DataSource.Glob as Glob
import Date exposing (Date)
import Element.Font exposing (external)
import OptimizedDecoder exposing (Decoder)
import OptimizedDecoder.Pipeline as OptimizedDecoder


projectsPath =
    "content/projects/"


projectsDataSource : DataSource (List Metadata)
projectsDataSource =
    Glob.succeed
        (\filePath slug ->
            { filePath = filePath
            , slug = slug
            }
        )
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal projectsPath)
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toDataSource
        |> DataSource.map
            (\projects ->
                List.map
                    (\project ->
                        DataSource.File.onlyFrontmatter (metadataDecoder project.slug) project.filePath
                    )
                    projects
            )
        |> DataSource.resolve


metadataDataSource : String -> DataSource Metadata
metadataDataSource slug =
    DataSource.File.onlyFrontmatter (metadataDecoder slug) (projectsPath ++ slug ++ ".md")


type alias Metadata =
    { slug : String
    , title : String
    , description : String
    , published : Date
    , image : String
    , draft : Bool
    , githubUrl : Maybe String
    , externalUrl : Maybe String
    }


metadataDecoder : String -> Decoder Metadata
metadataDecoder slug =
    OptimizedDecoder.decode (Metadata slug)
        |> OptimizedDecoder.required "title" OptimizedDecoder.string
        |> OptimizedDecoder.required "description" OptimizedDecoder.string
        |> OptimizedDecoder.required "published" dateDecoder
        |> OptimizedDecoder.required "image" OptimizedDecoder.string
        |> OptimizedDecoder.optional "draft" OptimizedDecoder.bool False
        |> OptimizedDecoder.optional "githubUrl" (OptimizedDecoder.map Just OptimizedDecoder.string) Nothing
        |> OptimizedDecoder.optional "externalUrl" (OptimizedDecoder.map Just OptimizedDecoder.string) Nothing


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
