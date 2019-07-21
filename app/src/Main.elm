port module Main exposing (main)

import Browser
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Json.Decode exposing (Decoder, Value, decodeValue, field, int, list, map, map2, string)
import Time exposing (Posix, millisToPosix)


port requestBlocked : (Value -> msg) -> Sub msg


main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }


type alias BlockedRequest =
    { url : String
    , date : Posix
    }


type alias Model =
    List BlockedRequest


type alias Flags =
    Value


decodePosix : Decoder Posix
decodePosix =
    map millisToPosix int


decodeBlockedRequest : Decoder BlockedRequest
decodeBlockedRequest =
    map2 BlockedRequest
        (field "url" string)
        (field "date" decodePosix)


init : Flags -> ( Model, Cmd msg )
init flags =
    let
        initRequests =
            decodeValue (list decodeBlockedRequest) flags

        requests =
            case initRequests of
                Ok parsed ->
                    parsed

                Err _ ->
                    []
    in
    ( requests, Cmd.none )


type Msg
    = RequestBlocked Value


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        RequestBlocked raw ->
            let
                decoded =
                    decodeValue decodeBlockedRequest raw

                newModel =
                    case decoded of
                        Ok blockedRequest ->
                            model ++ [ blockedRequest ]

                        Err _ ->
                            model
            in
            ( newModel, Cmd.none )


viewRequest : BlockedRequest -> Html Msg
viewRequest request =
    div [ class "blocked-request" ] [ text request.url ]


view : Model -> Html Msg
view model =
    div [] (List.map viewRequest model)


subscriptions : Model -> Sub Msg
subscriptions model =
    requestBlocked RequestBlocked
