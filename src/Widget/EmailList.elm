module Widget.EmailList exposing
    ( Model
    , applyResponse
    , init
    , makeRequest
    , updateEmail
    , view
    )

import Element
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Http
import ViewSettings exposing (ViewSettings)


type alias Model msg =
    { onChangeEmail : String -> msg
    , onSubscribe : msg
    , onResponse : Result Http.Error String -> msg
    , email : String
    , status : Status
    }


type Status
    = Gathering
    | Errored String
    | Loading
    | Subscribed


init :
    { onChangeEmail : String -> msg
    , onSubscribe : msg
    , onResponse : Result Http.Error String -> msg
    }
    -> Model msg
init opts =
    { onChangeEmail = opts.onChangeEmail
    , onSubscribe = opts.onSubscribe
    , onResponse = opts.onResponse
    , email = ""
    , status = Gathering
    }


view :
    ViewSettings
    -> Model msg
    -> Element.Element msg
view viewSettings { onChangeEmail, email, onSubscribe, status } =
    let
        fieldTextAndButton error =
            [ Element.row [ Element.width Element.fill ]
                [ case error of
                    Just errorStr ->
                        Element.el
                            [ Font.size viewSettings.font.size.sm
                            , Font.color viewSettings.font.color.error
                            ]
                        <|
                            Element.text errorStr

                    Nothing ->
                        Element.el
                            [ Font.size viewSettings.font.size.sm
                            ]
                        <|
                            Element.text "Join the mailing list"
                ]
            , Element.row
                [ Element.width Element.fill
                , Element.spacing viewSettings.spacing.xs
                ]
                [ input
                    { viewSettings = viewSettings
                    , label = "email address"
                    , placeholder = "Your email"
                    , onChange = onChangeEmail
                    , value = email
                    }
                , Input.button
                    [ Border.width 1
                    , Border.color viewSettings.font.color.secondary
                    , Font.color viewSettings.font.color.secondary
                    , Font.size viewSettings.font.size.sm
                    , Element.padding viewSettings.spacing.sm
                    ]
                    { onPress = Just onSubscribe
                    , label = Element.text "Subscribe"
                    }
                ]
            ]
    in
    Element.column
        [ Element.width (Element.fill |> Element.maximum 300)
        , Element.spacing viewSettings.spacing.xs
        ]
    <|
        case status of
            Gathering ->
                fieldTextAndButton Nothing

            Errored str ->
                fieldTextAndButton (Just str)

            Loading ->
                [ Element.paragraph [] [ Element.text "Subscribing..." ] ]

            Subscribed ->
                [ Element.paragraph [] [ Element.text "Thank you! We sent you a confirmation email, please click the link to finish the subscription process." ] ]


input :
    { viewSettings : ViewSettings
    , label : String
    , placeholder : String
    , onChange : String -> msg
    , value : String
    }
    -> Element.Element msg
input { viewSettings, label, placeholder, onChange, value } =
    Input.text
        [ Element.padding viewSettings.spacing.sm
        , Background.color viewSettings.color.contentBackground
        , Border.innerShadow
            { offset = ( 0, 2 )
            , size = 0
            , blur = 4
            , color = viewSettings.color.innerShadow
            }
        , Border.width 1
        , Border.color viewSettings.color.innerShadow
        , Font.size viewSettings.font.size.sm
        ]
        { label = Input.labelHidden label
        , onChange = onChange
        , placeholder =
            Just
                (Input.placeholder
                    [ Font.color viewSettings.font.color.secondary
                    , Font.size viewSettings.font.size.sm
                    ]
                 <|
                    Element.text placeholder
                )
        , text = value
        }


updateEmail : String -> Model msg -> Model msg
updateEmail newEmail model =
    { model | email = newEmail }


makeRequest : Model msg -> ( Model msg, Cmd msg )
makeRequest model =
    ( { model | status = Loading }
    , Http.post
        { url = "https://danmarcab.us19.list-manage.com/subscribe/post-json"
        , body =
            Http.multipartBody
                [ Http.stringPart "u" "6b434c346bfb22867cb459a12"
                , Http.stringPart "id" "c53aa45bf8"
                , Http.stringPart "MERGE0" model.email
                , Http.stringPart "gdpr[51033]" "Y"
                ]
        , expect = Http.expectString model.onResponse
        }
    )


type ResponseAnalysis
    = SuccessfullySubscribed
    | AlreadySubscribed
    | InvalidEmail
    | UnknownError


applyResponse : Result Http.Error String -> Model msg -> Model msg
applyResponse result model =
    case result of
        Err _ ->
            { model | status = Errored "Error, please try again" }

        Ok resp ->
            case analyseResponse resp of
                SuccessfullySubscribed ->
                    { model | status = Subscribed }

                AlreadySubscribed ->
                    { model | status = Errored "You are already subscribed" }

                InvalidEmail ->
                    { model | status = Errored "Invalid email" }

                UnknownError ->
                    { model | status = Errored "Error, please try again" }


analyseResponse : String -> ResponseAnalysis
analyseResponse resp =
    if String.contains "There are errors below" resp then
        if String.contains "is already subscribed" resp then
            AlreadySubscribed

        else
            InvalidEmail

    else if String.contains "We need to confirm your email address" resp then
        SuccessfullySubscribed

    else
        UnknownError
