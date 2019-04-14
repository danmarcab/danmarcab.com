module Util.Batcher exposing (Batcher(..), add, addMany, currentBatch, fullBatches, new)

import Array exposing (Array)


type Batcher a
    = Batcher
        { batchSize : Int
        , fullBatches : Array (Array a)
        , currentBatch : Array a
        }


new : Int -> Batcher a
new batchSize =
    Batcher
        { batchSize = batchSize
        , fullBatches = Array.empty
        , currentBatch = Array.empty
        }


add : a -> Batcher a -> Batcher a
add el (Batcher batcher) =
    let
        newCurrentBatch =
            Array.push el batcher.currentBatch
    in
    if Array.length newCurrentBatch == batcher.batchSize then
        Batcher
            { batchSize = batcher.batchSize
            , fullBatches = Array.push newCurrentBatch batcher.fullBatches
            , currentBatch = Array.empty
            }

    else
        Batcher
            { batchSize = batcher.batchSize
            , fullBatches = batcher.fullBatches
            , currentBatch = newCurrentBatch
            }


addMany : List a -> Batcher a -> Batcher a
addMany list batcher =
    List.foldl add batcher list


fullBatches : Batcher a -> Array (Array a)
fullBatches (Batcher batcher) =
    batcher.fullBatches


currentBatch : Batcher a -> Array a
currentBatch (Batcher batcher) =
    batcher.currentBatch
