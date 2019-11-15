module TreeDiagram exposing
    ( BoundingBox
    , Coord
    , Position
    , PositionedTree
    , Tree
    , draw
    , empty
    , node
    , position
    )


type Tree a
    = Empty
    | Node a (Tree a) (Tree a)


type alias Coord =
    ( Int, Int )


type alias Contour =
    List ( Int, Int )


type alias OffsetTree a =
    Tree ( a, Int )


type alias PositionedTree a =
    Tree ( a, Coord )


type alias Position =
    { x : Int, y : Int }


type alias BoundingBox =
    { fromX : Int, fromY : Int, toX : Int, toY : Int }


type alias Config data res =
    { nodeRadius : Int
    , subtreeDist : Int
    , levelHeight : Int
    , drawNode : Position -> data -> res
    , drawEdge : ( Position, data ) -> ( Position, data ) -> res
    , compose : BoundingBox -> List res -> res
    }


draw :
    Config data res
    -> Tree data
    -> res
draw { nodeRadius, subtreeDist, levelHeight, drawNode, drawEdge, compose } tree =
    let
        ( positionedTree, boundingBox ) =
            position
                { nodeRadius = nodeRadius
                , subtreeDist = subtreeDist
                , levelHeight = levelHeight
                }
                tree

        ( nodes, edges ) =
            traverse positionedTree
    in
    compose boundingBox
        (List.map (\( parent, child ) -> drawEdge parent child) edges
            ++ List.map (\( pos, data ) -> drawNode pos data) nodes
        )


traverse : PositionedTree a -> ( List ( Position, a ), List ( ( Position, a ), ( Position, a ) ) )
traverse positionedTree =
    let
        buildNode ( val, ( x, y ) ) =
            ( { x = x, y = y }, val )

        buildEdge ( val, ( x, y ) ) ( childVal, ( childX, childY ) ) =
            ( ( { x = x, y = y }, val ), ( { x = childX, y = childY }, childVal ) )

        help currNode nodes edges =
            case currNode of
                Empty ->
                    ( nodes, edges )

                Node data Empty Empty ->
                    ( buildNode data :: nodes, edges )

                Node data ((Node childData _ _) as child) Empty ->
                    help child
                        (buildNode data :: nodes)
                        (buildEdge data childData :: edges)

                Node data Empty ((Node childData _ _) as child) ->
                    help child
                        (buildNode data :: nodes)
                        (buildEdge data childData :: edges)

                Node data ((Node leftData _ _) as leftChild) ((Node rightData _ _) as rightChild) ->
                    let
                        ( nodesWithLeft, edgeswithLeft ) =
                            help leftChild
                                (buildNode data :: nodes)
                                (buildEdge data leftData :: buildEdge data rightData :: edges)
                    in
                    help rightChild
                        nodesWithLeft
                        edgeswithLeft
    in
    help positionedTree [] []


empty : Tree a
empty =
    Empty


node : a -> Tree a -> Tree a -> Tree a
node val left right =
    Node val left right


type alias PositionConfig =
    { nodeRadius : Int, subtreeDist : Int, levelHeight : Int }


position :
    PositionConfig
    -> Tree a
    -> ( PositionedTree a, BoundingBox )
position config tree =
    let
        ( offsetTree, contour ) =
            offset config tree
    in
    ( place config { currentOffset = 0, level = 0 } offsetTree
    , contourToBoundingBox config contour
    )


contourToBoundingBox : PositionConfig -> Contour -> BoundingBox
contourToBoundingBox config contour =
    let
        nLevels =
            List.length contour
    in
    { fromX = (contour |> List.map Tuple.first |> List.minimum |> Maybe.withDefault 0) - config.nodeRadius
    , toX = (contour |> List.map Tuple.second |> List.maximum |> Maybe.withDefault 0) + config.nodeRadius
    , fromY = -config.nodeRadius
    , toY = config.levelHeight * (nLevels - 1) + config.nodeRadius
    }


transformContour : Int -> Contour -> Contour
transformContour delta contour =
    List.map (\( left, right ) -> ( left + delta, right + delta )) contour


offset : PositionConfig -> Tree a -> ( OffsetTree a, Contour )
offset config tree =
    case tree of
        Empty ->
            ( Empty, [] )

        Node info Empty Empty ->
            ( Node ( info, 0 ) Empty Empty, [ ( 0, 0 ) ] )

        Node info Empty right ->
            let
                ( rightOffset, rightContour ) =
                    offset config right

                rootOffset =
                    config.subtreeDist // 2
            in
            ( Node ( info, rootOffset ) Empty rightOffset
            , ( 0, 0 ) :: transformContour rootOffset rightContour
            )

        Node info left Empty ->
            let
                ( leftOffset, leftContour ) =
                    offset config left

                rootOffset =
                    config.subtreeDist // 2
            in
            ( Node ( info, rootOffset ) leftOffset Empty
            , ( 0, 0 ) :: transformContour -rootOffset leftContour
            )

        Node info left right ->
            let
                ( leftOffset, leftContour ) =
                    offset config left

                ( rightOffset, rightContour ) =
                    offset config right

                subTreeOffset =
                    minContourOffset config leftContour rightContour

                rootOffset =
                    subTreeOffset // 2

                combinedContour =
                    combineContours
                        (transformContour -rootOffset leftContour)
                        (transformContour rootOffset rightContour)
            in
            ( Node ( info, rootOffset ) leftOffset rightOffset
            , ( 0, 0 ) :: combinedContour
            )


minContourOffset : PositionConfig -> Contour -> Contour -> Int
minContourOffset config leftContour rightContour =
    let
        help left right currDist =
            case ( left, right ) of
                ( ( _, leftTo ) :: moreLeft, ( rightFrom, _ ) :: moreRight ) ->
                    help moreLeft moreRight (max (leftTo - rightFrom) currDist)

                _ ->
                    currDist
    in
    help leftContour rightContour 0 + config.subtreeDist


combineContours : Contour -> Contour -> Contour
combineContours leftContour rightContour =
    let
        help left right revCombinedContour =
            case ( left, right ) of
                ( [], [] ) ->
                    List.reverse revCombinedContour

                ( ( leftFrom, _ ) :: moreLeft, ( _, rightTo ) :: moreRight ) ->
                    help moreLeft moreRight (( leftFrom, rightTo ) :: revCombinedContour)

                ( leftLevel :: moreLeft, [] ) ->
                    help moreLeft [] (leftLevel :: revCombinedContour)

                ( [], rightLevel :: moreRight ) ->
                    help [] moreRight (rightLevel :: revCombinedContour)
    in
    help leftContour rightContour []


place : PositionConfig -> { currentOffset : Int, level : Int } -> OffsetTree a -> PositionedTree a
place config { currentOffset, level } tree =
    case tree of
        Empty ->
            Empty

        Node ( info, off ) left right ->
            Node ( info, ( currentOffset, level * config.levelHeight ) )
                (place config { currentOffset = currentOffset - off, level = level + 1 } left)
                (place config { currentOffset = currentOffset + off, level = level + 1 } right)
