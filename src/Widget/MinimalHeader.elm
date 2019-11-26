module Widget.MinimalHeader exposing (view)

import Element exposing (Element)
import Element.Border as Border
import ViewSettings exposing (ViewSettings)
import Widget.Sitename as Sitename


view : { viewSettings : ViewSettings } -> Element msg
view { viewSettings } =
    Element.row
        [ Element.width Element.shrink
        , Element.spaceEvenly
        , Border.widthEach
            { top = 0
            , right = 0
            , bottom = 5
            , left = 0
            }
        , Element.padding viewSettings.spacing.sm
        ]
        [ Sitename.view viewSettings
        ]
