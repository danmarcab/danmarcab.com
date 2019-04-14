module Page.Home exposing (Msg(..), view)

import Element exposing (Element)


type Msg
    = Msg


view : { title : String, body : Element Msg }
view =
    { title = "Home"
    , body = Element.text "Home"
    }
