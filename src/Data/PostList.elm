module Data.PostList exposing
    ( PostList
    , decoder
    , empty
    , filter
    , get
    , map
    )

import AssocList
import Data.Post as Post exposing (Post)
import Json.Decode as JD exposing (Decoder)
import Mark
import Mark.Error
import Time


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
        |> List.map (\( _, post ) -> mapper post)


filter : (Post -> Bool) -> PostList -> PostList
filter f (PostList postList) =
    AssocList.filter (\_ post -> f post) postList
        |> PostList


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
                JD.succeed ( PostList posts |> sort, errors )
            )


sort : PostList -> PostList
sort (PostList postList) =
    postList
        |> AssocList.toList
        |> List.sortBy (\( _, post ) -> Time.posixToMillis post.publishedDate)
        |> AssocList.fromList
        |> PostList
