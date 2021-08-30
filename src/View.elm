module View exposing (View, map, placeholder)

import Element exposing (Element)


type alias View msg =
    { title : String, body : Element msg, fillHeight : Bool }


map : (msg1 -> msg2) -> View msg1 -> View msg2
map fn doc =
    { title = doc.title
    , body = Element.map fn doc.body
    , fillHeight = doc.fillHeight
    }


placeholder : String -> View msg
placeholder moduleName =
    { title = "Placeholder - " ++ moduleName
    , body = Element.text moduleName
    , fillHeight = False
    }
