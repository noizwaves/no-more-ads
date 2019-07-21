port module Main exposing (main)

import Browser
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)


port requestBlocked : (String -> msg) -> Sub msg


main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }


type alias Model =
    List String


init : () -> ( Model, Cmd msg )
init flags =
    ( [], Cmd.none )


type Msg
    = RequestBlocked String


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        RequestBlocked url ->
            ( model ++ [ url ], Cmd.none )


viewRequest : String -> Html Msg
viewRequest url =
    div [ class "blocked-request" ] [ text url ]


view : Model -> Html Msg
view model =
    div [] (List.map viewRequest model)


subscriptions : Model -> Sub Msg
subscriptions model =
    requestBlocked RequestBlocked
