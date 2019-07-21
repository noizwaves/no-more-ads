port module Main exposing (main)

import Browser
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Time exposing (Posix, millisToPosix)


port requestBlocked : (BlockedRequestJson -> msg) -> Sub msg


main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }


type alias BlockedRequest =
    { url : String
    , date : Posix
    }


type alias Model =
    List BlockedRequest


type alias BlockedRequestJson =
    { url : String
    , date : Int
    }


type alias Flags =
    List BlockedRequestJson


toBlockedRequest : BlockedRequestJson -> BlockedRequest
toBlockedRequest json =
    { url = json.url
    , date = millisToPosix json.date
    }


init : Flags -> ( Model, Cmd msg )
init flags =
    let
        requests =
            List.map toBlockedRequest flags
    in
    ( requests, Cmd.none )


type Msg
    = RequestBlocked BlockedRequestJson


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        RequestBlocked json ->
            ( model ++ [ toBlockedRequest json ], Cmd.none )


viewRequest : BlockedRequest -> Html Msg
viewRequest request =
    div [ class "blocked-request" ] [ text request.url ]


view : Model -> Html Msg
view model =
    div [] (List.map viewRequest model)


subscriptions : Model -> Sub Msg
subscriptions _ =
    requestBlocked RequestBlocked
