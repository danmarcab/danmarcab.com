module Widget.EmailList exposing (..)

import Element
import Element.Font as Font
import ViewSettings exposing (ViewSettings)


sitename : String
sitename =
    "JOIN EMAIL"


view : ViewSettings -> Element.Element msg
view viewSettings =
    Element.link []
        { url = "/"
        , label =
            Element.el
                [ Font.size viewSettings.font.size.xl
                , Font.bold
                ]
            <|
                Element.text sitename
        }
