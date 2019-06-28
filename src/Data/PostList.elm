module Data.PostList exposing
    ( PostList
    , decoder
    , empty
    , get
    , map
    )

import AssocList
import Data.Post as Post exposing (Post)
import Json.Decode as JD exposing (Decoder)
import Mark
import Mark.Error


type PostList
    = PostList (AssocList.Dict String Post)


type alias Error =
    String


empty : PostList
empty =
    PostList AssocList.empty


get : String -> PostList -> Maybe Post
get id (PostList postList) =
    AssocList.get id postList


map : (Post -> a) -> PostList -> List a
map mapper (PostList postList) =
    AssocList.toList postList
        |> List.map (\( id, post ) -> mapper post)


fromPostList : List Post -> ( PostList, List Error )
fromPostList posts =
    let
        sortedPosts =
            posts
                |> List.sortWith Post.dateSorter

        sameIdErrorMsg p1 p2 =
            "Posts with titles: " ++ p1.title ++ " , and " ++ p2.title ++ " both have the same id: " ++ p1.id

        step post ( postList, errors ) =
            case AssocList.get post.id postList of
                Just postWithSameId ->
                    ( postList, errors ++ [ sameIdErrorMsg post postWithSameId ] )

                Nothing ->
                    ( AssocList.insert post.id post postList, errors )
    in
    List.foldl step ( AssocList.empty, [] ) sortedPosts
        |> Tuple.mapFirst PostList


decoder : Decoder ( PostList, List Error )
decoder =
    JD.keyValuePairs JD.string
        |> JD.andThen
            (\kvPairs ->
                let
                    ( posts, errors ) =
                        List.foldl
                            (\( file, content ) ( accPosts, accErrors ) ->
                                case Post.fromFileAndMarkup file content of
                                    Mark.Success post ->
                                        ( AssocList.insert post.id post accPosts, accErrors )

                                    Mark.Almost partial ->
                                        ( AssocList.insert partial.result.id partial.result accPosts
                                        , accErrors ++ List.map Mark.Error.toString partial.errors
                                        )

                                    Mark.Failure errorList ->
                                        ( accPosts, accErrors ++ List.map Mark.Error.toString errorList )
                            )
                            ( AssocList.empty, [] )
                            kvPairs
                in
                JD.succeed ( PostList posts, errors )
            )
