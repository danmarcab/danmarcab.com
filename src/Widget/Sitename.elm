module Widget.Sitename exposing (view)

import Element exposing (Element)
import Element.Font as Font
import ViewSettings exposing (ViewSettings)


sitename : String
sitename =
    "danmarcab.com"


view : ViewSettings -> Element msg
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
