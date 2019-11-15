module Widget.Figure exposing (..)

import Element exposing (Element)
import Element.Font as Font
import ViewSettings exposing (ViewSettings)


view : ViewSettings -> String -> Element msg -> Element msg
view viewSettings description figureView =
    Element.column
        [ Element.centerX
        , Element.spacing viewSettings.spacing.sm
        , Element.width Element.fill
        ]
        [ figureView
        , Element.paragraph
            [ Font.center
            , Font.color viewSettings.font.color.secondary
            , Font.size viewSettings.font.size.sm
            ]
            [ Element.text description ]
        ]
