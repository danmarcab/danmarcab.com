module Util.Collection exposing
    ( Collection(..)
    , append
    , empty
    , fromItems
    , get
    , indices
    , insert
    , insertMany
    , isEmpty
    , items
    , remove
    , size
    )

import Dict exposing (Dict)


type Collection a
    = Collection
        { nextId : Int
        , items : Dict Int a
        }


empty : Collection a
empty =
    Collection
        { nextId = 1
        , items = Dict.empty
        }


fromItems : List a -> Collection a
fromItems list =
    List.foldl insert empty list


indices : Collection a -> List Int
indices (Collection collection) =
    Dict.keys collection.items


items : Collection a -> List a
items (Collection collection) =
    Dict.values collection.items


isEmpty : Collection a -> Bool
isEmpty (Collection collection) =
    Dict.isEmpty collection.items


insert : a -> Collection a -> Collection a
insert a (Collection collection) =
    Collection
        { nextId = collection.nextId + 1
        , items = Dict.insert collection.nextId a collection.items
        }


insertMany : List a -> Collection a -> Collection a
insertMany list collection =
    List.foldl insert collection list


remove : Int -> Collection a -> Collection a
remove idx (Collection collection) =
    Collection
        { nextId = collection.nextId
        , items = Dict.remove idx collection.items
        }


size : Collection a -> Int
size (Collection collection) =
    Dict.size collection.items


get : Int -> Collection a -> Maybe a
get idx (Collection collection) =
    Dict.get idx collection.items


append : Collection a -> Collection a -> Collection a
append collection1 collection2 =
    insertMany (items collection2) collection1
