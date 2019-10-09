module Widget.Header exposing (view)

import Element exposing (Element)
import ViewSettings exposing (ViewSettings)
import Widget.EmailList
import Widget.Sitename as Sitename


view : ViewSettings -> { description : String } -> Element msg
view viewSettings { description } =
    Element.row
        [ Element.width Element.fill
        , Element.spaceEvenly
        ]
        [ Element.column [ Element.spacing viewSettings.spacing.md ]
            [ Sitename.view viewSettings
            , Element.text description
            ]
        , Widget.EmailList.view viewSettings
        ]
