module Page.QuadDivision exposing (Model, Msg, init, subscriptions, update, view)

import Art.QuadDivision as QuadDivision
import Browser.Dom exposing (Viewport)
import Browser.Events
import Element exposing (Element)
import Random
import Task
import Time


type Model
    = Initial
    | Started QuadDivision.Model


type Msg
    = Subdivide
    | Resized
    | InitSeed Int
    | Initialize Int Viewport


init : ( Model, Cmd Msg )
init =
    ( Initial
    , Random.generate InitSeed anyInt
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg fullModel =
    case ( msg, fullModel ) of
        ( Subdivide, Started model ) ->
            ( Started (QuadDivision.subdivide model)
            , Cmd.none
            )

        ( Subdivide, _ ) ->
            ( fullModel
            , Cmd.none
            )

        ( Resized, _ ) ->
            ( fullModel, Random.generate InitSeed anyInt )

        ( InitSeed seed, _ ) ->
            ( Initial
            , Task.perform (Initialize seed) Browser.Dom.getViewport
            )

        ( Initialize seed vieport, _ ) ->
            ( Started <| QuadDivision.initialize seed vieport
            , Cmd.none
            )


view : Model -> { title : String, body : Element Msg }
view fullModel =
    { title = "Quad Division"
    , body =
        case fullModel of
            Initial ->
                Element.text "Loading..."

            Started model ->
                Element.map never <|
                    Element.html (QuadDivision.view model)
    }


subscriptions : Model -> Sub Msg
subscriptions fullModel =
    case fullModel of
        Initial ->
            Sub.none

        Started model ->
            Sub.batch
                [ if QuadDivision.done model then
                    Sub.none

                  else
                    Time.every 100 (always Subdivide)
                , Browser.Events.onResize (\w h -> Resized)
                ]



-- RANDOM GENERATORS


anyInt : Random.Generator Int
anyInt =
    Random.int Random.minInt Random.maxInt
