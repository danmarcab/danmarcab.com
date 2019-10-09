module Widget.Header exposing (..)

import Element exposing (Element)
import Element.Font as Font
import Metadata exposing (HomepageMetadata)
import Pages
import Pages.Platform exposing (Page)
import ViewSettings exposing (ViewSettings)
import Widget.EmailList
import Widget.Sitename as Sitename


sitename : String
sitename =
    "danmarcab.com"


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
