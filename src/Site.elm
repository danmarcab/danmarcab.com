module Site exposing (config)

import DataSource
import Head
import MimeType
import Pages.Manifest as Manifest
import Pages.Url
import Path
import Route
import SiteConfig exposing (SiteConfig)


type alias Data =
    ()


config : SiteConfig Data
config =
    { data = data
    , canonicalUrl = "https://danmarcab.com"
    , manifest = manifest
    , head = head
    }


data : DataSource.DataSource Data
data =
    DataSource.succeed ()


head : Data -> List Head.Tag
head static =
    [ Head.icon [ ( 256, 256 ) ] (MimeType.OtherImage "Svg") (Pages.Url.fromPath (Path.join [ "images", "icon.svg" ]))
    , Head.sitemapLink "/sitemap.xml"
    ]


manifest : Data -> Manifest.Config
manifest static =
    Manifest.init
        { name = "Site Name"
        , description = "Description"
        , startUrl = Route.Index |> Route.toPath
        , icons =
            [ icon (MimeType.OtherImage "Svg") 32
            ]
        }


icon :
    MimeType.MimeImage
    -> Int
    -> Manifest.Icon
icon format width =
    { src = Pages.Url.fromPath (Path.join [ "images", "icon.svg" ])
    , sizes = [ ( width, width ) ]
    , mimeType = format |> Just
    , purposes = [ Manifest.IconPurposeAny, Manifest.IconPurposeMaskable ]
    }
