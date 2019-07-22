port module Main exposing (main)

import Browser
import Dict
import Html exposing (Html, div, h2, h3, i, text)
import Html.Attributes exposing (class)
import Time exposing (Posix, every, millisToPosix, posixToMillis)


port requestBlocked : (BlockedRequestJson -> msg) -> Sub msg


main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }


type alias BlockedRequest =
    { url : String
    , host : String
    , date : Posix
    }


type alias Model =
    { blockedRequests : List BlockedRequest
    , currently : Posix
    }


type alias BlockedRequestJson =
    { url : String
    , host : String
    , date : Int
    }


type alias Flags =
    { blockedRequests : List BlockedRequestJson
    , currently : Int
    }


toBlockedRequest : BlockedRequestJson -> BlockedRequest
toBlockedRequest json =
    { url = json.url
    , host = json.host
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
    let
        content =
            case requests of
                [] ->
                    [ i [] [ text "none" ] ]

                _ ->
                    List.map viewRequest requests
    in
    div []
        [ h3 [] [ text name ]
        , div [] content
        ]


viewRequestsByHost : ( String, Int ) -> Html Msg
viewRequestsByHost ( host, count ) =
    div []
        [ text "("
        , text <| String.fromInt count
        , text ") "
        , text host
        ]


viewSummary : Model -> Html Msg
viewSummary model =
    let
        reduceCount key dict =
            let
                updateF : Maybe Int -> Maybe Int
                updateF mv =
                    case mv of
                        Nothing ->
                            Just 1

                        Just v ->
                            Just (v + 1)
            in
            Dict.update key updateF dict

        counts =
            model.blockedRequests
                |> List.map .host
                |> List.foldr reduceCount Dict.empty
                |> Dict.toList
                |> List.sortBy (\( _, v ) -> v)
                |> List.reverse

        requestsByHost =
            counts
                |> List.map viewRequestsByHost
    in
    div []
        (h2 [] [ text "Summary" ] :: requestsByHost)


viewLog : Model -> Html Msg
viewLog model =
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
        [ h2 [] [ text "Log" ]
        , viewRequestRange "Last minute" current
        , viewRequestRange "Last 15 minutes" recent
        , viewRequestRange "Older than 15 minutes" old
        ]


view : Model -> Html Msg
view model =
    div []
        [ viewSummary model
        , viewLog model
        ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ requestBlocked RequestBlocked
        , every 1000 Tick
        ]
