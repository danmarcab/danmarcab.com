module Metadata exposing (HomepageMetadata, Metadata(..), PostMetadata, ProjectMetadata, decoder)

import Date exposing (Date)
import Dict exposing (Dict)
import Element exposing (Element)
import Json.Decode as Decode exposing (Decoder)
import List.Extra
import Pages
import Pages.ImagePath as ImagePath exposing (ImagePath)


type Metadata
    = Homepage HomepageMetadata
    | Post PostMetadata
    | Project ProjectMetadata


type alias HomepageMetadata =
    { title : String
    , description : String
    }


type alias PostMetadata =
    { title : String
    , description : String
    , published : Date
    , image : ImagePath Pages.PathKey
    , draft : Bool
    }


type alias ProjectMetadata =
    { title : String
    , description : String
    , published : Date
    , image : ImagePath Pages.PathKey
    , draft : Bool
    , githubUrl : Maybe String
    , externalUrl : Maybe String
    }


decoder =
    Decode.field "type" Decode.string
        |> Decode.andThen
            (\pageType ->
                case pageType of
                    "homepage" ->
                        Decode.map2 HomepageMetadata
                            (Decode.field "title" Decode.string)
                            (Decode.field "description" Decode.string)
                            |> Decode.map Homepage

                    "post" ->
                        Decode.map5 PostMetadata
                            (Decode.field "title" Decode.string)
                            (Decode.field "description" Decode.string)
                            (Decode.field "published" dateDecoder)
                            (Decode.field "image" imageDecoder)
                            (Decode.field "draft" Decode.bool
                                |> Decode.maybe
                                |> Decode.map (Maybe.withDefault False)
                            )
                            |> Decode.map Post

                    "project" ->
                        Decode.map7 ProjectMetadata
                            (Decode.field "title" Decode.string)
                            (Decode.field "description" Decode.string)
                            (Decode.field "published" dateDecoder)
                            (Decode.field "image" imageDecoder)
                            (Decode.field "draft" Decode.bool
                                |> Decode.maybe
                                |> Decode.map (Maybe.withDefault False)
                            )
                            (Decode.field "githubUrl" Decode.string |> Decode.maybe)
                            (Decode.field "externalUrl" Decode.string |> Decode.maybe)
                            |> Decode.map Project

                    _ ->
                        Decode.fail <| "Unexpected page type " ++ pageType
            )


dateDecoder : Decoder Date
dateDecoder =
    Decode.string
        |> Decode.andThen
            (\isoString ->
                case Date.fromIsoString isoString of
                    Ok date ->
                        Decode.succeed date

                    Err error ->
                        Decode.fail error
            )


imageDecoder : Decoder (ImagePath Pages.PathKey)
imageDecoder =
    Decode.string
        |> Decode.andThen
            (\imageAssetPath ->
                case findMatchingImage imageAssetPath of
                    Nothing ->
                        Decode.fail "Couldn't find image."

                    Just imagePath ->
                        Decode.succeed imagePath
            )


findMatchingImage : String -> Maybe (ImagePath Pages.PathKey)
findMatchingImage imageAssetPath =
    Pages.allImages
        |> List.Extra.find
            (\image ->
                ImagePath.toString image
                    == imageAssetPath
            )
