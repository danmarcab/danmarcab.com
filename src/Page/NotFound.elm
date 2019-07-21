module Page.NotFound exposing (view)

import Config exposing (Config)
import Element exposing (Element)
import Element.Font as Font
import Layout.Page


view : Config -> { title : String, body : Element msg }
view config =
    { title = "Not Found"
    , body =
        Layout.Page.view config
            { pageTitle = "Not Found"
            , contentView = contentView config
            }
    }


contentView : Config -> Element msg
contentView config =
    Element.column
        [ Element.centerX
        , Element.centerY
        , Font.size config.fontSize.large
        , Element.spacing config.spacing.medium
        ]
        [ Element.paragraph [ Element.centerX ]
            [ Element.text "We couldn't find the URL you entered. Please go back to the homepage" ]
        , Element.link
            [ Font.color config.colors.primary
            , Element.centerX
            ]
            { url = "/", label = Element.text "Click to go back to the Homepage" }
        ]
