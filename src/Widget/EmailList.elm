module Widget.EmailList exposing (view)

import Element
import Element.Font as Font
import ViewSettings exposing (ViewSettings)


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
                Element.text "JOIN EMAIL"
        }
