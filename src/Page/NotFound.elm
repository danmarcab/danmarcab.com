module Page.NotFound exposing (view)

import Element exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Layout.Page
import Style.Color as Color


view : { colorScheme : Color.Scheme } -> { title : String, body : Element msg }
view { colorScheme } =
    { title = "Not Found"
    , body =
        Layout.Page.view { colorScheme = colorScheme }
            { pageTitle = "Not Found"
            , contentView = contentView { colorScheme = colorScheme }
            }
    }


contentView : { colorScheme : Color.Scheme } -> Element msg
contentView { colorScheme } =
    Element.column
        [ Element.centerX
        , Element.centerY
        , Font.size 24
        , Element.spacing 20
        ]
        [ Element.paragraph [ Element.centerX ] [ Element.text "We couldn't find the URL you entered. Please go back to the homepage" ]
        , Element.link
            [ Font.color (Color.primary colorScheme)
            , Element.centerX
            ]
            { url = "/", label = Element.text "Click to go back to the Homepage" }
        ]
