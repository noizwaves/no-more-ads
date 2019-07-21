port module Main exposing (main)

import Browser
import Html exposing (Html, div, h3, text)
import Html.Attributes exposing (class)
import Time exposing (Posix, every, millisToPosix, posixToMillis)


port requestBlocked : (BlockedRequestJson -> msg) -> Sub msg


main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }


type alias BlockedRequest =
    { url : String
    , date : Posix
    }


type alias Model =
    { blockedRequests : List BlockedRequest
    , currently : Posix
    }


type alias BlockedRequestJson =
    { url : String
    , date : Int
    }


type alias Flags =
    { blockedRequests : List BlockedRequestJson
    , currently : Int
    }


toBlockedRequest : BlockedRequestJson -> BlockedRequest
toBlockedRequest json =
    { url = json.url
    , date = millisToPosix json.date
    }


init : Flags -> ( Model, Cmd msg )
init flags =
    let
        requests =
            flags.blockedRequests |> List.map toBlockedRequest
    in
    ( { blockedRequests = requests, currently = millisToPosix flags.currently }, Cmd.none )


type Msg
    = RequestBlocked BlockedRequestJson
    | Tick Posix


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        RequestBlocked json ->
            ( { model | blockedRequests = model.blockedRequests ++ [ toBlockedRequest json ] }, Cmd.none )

        Tick time ->
            ( { model | currently = time }, Cmd.none )


viewRequest : BlockedRequest -> Html Msg
viewRequest request =
    div [ class "blocked-request" ] [ text request.url ]


viewRequestRange : String -> List BlockedRequest -> Html Msg
viewRequestRange name requests =
    div []
        [ h3 [] [ text name ]
        , div [] (List.map viewRequest requests)
        ]


view : Model -> Html Msg
view model =
    let
        newestFirst =
            model.blockedRequests
                |> List.sortBy (\br -> br.date |> posixToMillis)
                |> List.reverse

        now =
            model.currently |> posixToMillis

        ( current, other ) =
            newestFirst
                |> List.partition (\r -> posixToMillis r.date > now - (60 * 1000))

        ( recent, old ) =
            other
                |> List.partition (\r -> posixToMillis r.date > now - (15 * 60 * 1000))
    in
    div []
        [ viewRequestRange "Last minute" current
        , viewRequestRange "Last 15 minutes" recent
        , viewRequestRange "Older than 15 minutes" old
        ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ requestBlocked RequestBlocked
        , every 1000 Tick
        ]
