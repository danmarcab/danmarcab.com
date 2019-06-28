module Page.NotFound exposing (view)

import Element exposing (Element)
import Element.Background as Background
import Element.Font as Font


view : { title : String, body : Element msg }
view =
    { title = "Not Found"
    , body =
        Element.el
            [ Element.width Element.fill
            , Background.color (Element.rgba255 0 0 0 0.9)
            , Font.color (Element.rgba255 255 255 255 1)
            , Element.height Element.fill
            ]
            (Element.el
                [ Element.centerX
                , Element.centerY
                , Font.size 24
                ]
             <|
                Element.link [ Font.color (Element.rgba255 255 255 255 1) ]
                    { url = "/", label = Element.text "Click to go back to the Homepage" }
            )
    }
