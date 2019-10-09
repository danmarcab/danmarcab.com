module Widget.Header exposing (view)

import Element exposing (Element)
import Element.Border as Border
import ViewSettings exposing (ViewSettings)
import Widget.EmailList
import Widget.Sitename as Sitename


view : ViewSettings -> { description : String } -> Element msg
view viewSettings { description } =
    Element.row
        [ Element.width Element.fill
        , Element.spaceEvenly
        , Border.widthEach
            { top = 0
            , right = 0
            , bottom = 5
            , left = 0
            }
        , Element.paddingEach
            { top = 0
            , right = 0
            , bottom = viewSettings.spacing.sm
            , left = 0
            }
        ]
        [ Element.column
            [ Element.spacing viewSettings.spacing.sm
            , Element.width Element.fill
            , Element.paddingEach
                { top = 0
                , right = viewSettings.spacing.lg
                , bottom = 0
                , left = 0
                }
            ]
            [ Sitename.view viewSettings
            , Element.paragraph [] [ Element.text description ]
            ]
        , Widget.EmailList.view viewSettings
        ]
