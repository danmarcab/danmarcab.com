module TreeDiagramTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import TreeDiagram exposing (PositionedTree, Tree, empty, node)


suite : Test
suite =
    describe "position"
        (List.map
            (\example ->
                test example.description <|
                    \_ ->
                        TreeDiagram.position config example.input
                            |> Expect.equal example.expected
            )
            examples
        )


config : { subtreeDist : Int, levelHeight : Int }
config =
    { subtreeDist = 20
    , levelHeight = 20
    }


examples : List { description : String, input : Tree Int, expected : PositionedTree Int }
examples =
    [ { description = "empty"
      , input = empty
      , expected = empty
      }
    , { description = "single node"
      , input = node 1 empty empty
      , expected = node ( 1, ( 0, 0 ) ) empty empty
      }
    , { description = "root and left child"
      , input =
            node 1
                (node 2 empty empty)
                empty
      , expected =
            node ( 1, ( 0, 0 ) )
                (node ( 2, ( -10, 20 ) ) empty empty)
                empty
      }
    , { description = "root and right child"
      , input =
            node 1
                empty
                (node 2 empty empty)
      , expected =
            node ( 1, ( 0, 0 ) )
                empty
                (node ( 2, ( 10, 20 ) ) empty empty)
      }
    , { description = "root and both children"
      , input =
            node 2
                (node 1 empty empty)
                (node 3 empty empty)
      , expected =
            node ( 2, ( 0, 0 ) )
                (node ( 1, ( -10, 20 ) ) empty empty)
                (node ( 3, ( 10, 20 ) ) empty empty)
      }
    , { description = "a bit bigger"
      , input =
            node 8
                (node 4
                    empty
                    (node 6
                        empty
                        (node 7 empty empty)
                    )
                )
                (node 9 empty empty)
      , expected =
            node ( 8, ( 0, 0 ) )
                (node ( 4, ( -10, 20 ) )
                    empty
                    (node ( 6, ( 0, 40 ) )
                        empty
                        (node ( 7, ( 10, 60 ) ) empty empty)
                    )
                )
                (node ( 9, ( 10, 20 ) ) empty empty)
      }
    , { description = "a bit bigger 2"
      , input =
            node 8
                (node 4
                    empty
                    (node 6
                        (node 5 empty empty)
                        (node 7 empty empty)
                    )
                )
                (node 9 empty empty)
      , expected =
            node ( 8, ( 0, 0 ) )
                (node ( 4, ( -10, 20 ) )
                    empty
                    (node ( 6, ( 0, 40 ) )
                        (node ( 5, ( -10, 60 ) ) empty empty)
                        (node ( 7, ( 10, 60 ) ) empty empty)
                    )
                )
                (node ( 9, ( 10, 20 ) ) empty empty)
      }
    , { description = "a bit bigger 3"
      , input =
            node 8
                (node 4
                    (node 2 empty empty)
                    (node 6
                        (node 5 empty empty)
                        (node 7 empty empty)
                    )
                )
                (node 9 empty empty)
      , expected =
            node ( 8, ( 0, 0 ) )
                (node ( 4, ( -10, 20 ) )
                    (node ( 2, ( -20, 40 ) ) empty empty)
                    (node ( 6, ( 0, 40 ) )
                        (node ( 5, ( -10, 60 ) ) empty empty)
                        (node ( 7, ( 10, 60 ) ) empty empty)
                    )
                )
                (node ( 9, ( 10, 20 ) ) empty empty)
      }
    , { description = "a bit bigger 4"
      , input =
            node 8
                (node 4
                    (node 2
                        (node 1 empty empty)
                        (node 3 empty empty)
                    )
                    (node 6
                        (node 5 empty empty)
                        (node 7 empty empty)
                    )
                )
                (node 9 empty empty)
      , expected =
            node ( 8, ( 0, 0 ) )
                (node ( 4, ( -10, 20 ) )
                    (node ( 2, ( -30, 40 ) )
                        (node ( 1, ( -40, 60 ) ) empty empty)
                        (node ( 3, ( -20, 60 ) ) empty empty)
                    )
                    (node ( 6, ( 10, 40 ) )
                        (node ( 5, ( 0, 60 ) ) empty empty)
                        (node ( 7, ( 20, 60 ) ) empty empty)
                    )
                )
                (node ( 9, ( 10, 20 ) ) empty empty)
      }
    ]
