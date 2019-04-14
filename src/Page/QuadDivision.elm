module Page.QuadDivision exposing (Msg(..), view)

import Element exposing (Element)


type Msg
    = Msg


view : { title : String, body : Element Msg }
view =
    { title = "Quad Division"
    , body = Element.text "Quad Division"
    }
