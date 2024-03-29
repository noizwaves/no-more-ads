port module Main exposing (main)

import Browser
import Dict
import Html exposing (Html, div, h2, h3, i, text)
import Html.Attributes exposing (class)
import Time exposing (Posix, every, millisToPosix, posixToMillis)


port requestBlocked : (BlockedRequestJson -> msg) -> Sub msg


type alias BlockedRequest =
    { url : String
    , host : String
    , date : Posix
    }


type Recency
    = Current
    | Recent
    | Old


type alias LogEntry =
    { url : String
    , recency : Recency
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


toBlockedRequest : BlockedRequestJson -> BlockedRequest
toBlockedRequest json =
    { url = json.url
    , host = json.host
    , date = millisToPosix json.date
    }


toLogEntry : Posix -> BlockedRequest -> LogEntry
toLogEntry now value =
    let
        age =
            posixToMillis now - posixToMillis value.date

        recency =
            if age > (15 * 60 * 1000) then
                Old

            else if age > (60 * 1000) then
                Recent

            else
                Current
    in
    { url = value.url
    , recency = recency
    }


toLogEntries : Posix -> List BlockedRequest -> List LogEntry
toLogEntries now value =
    value
        |> List.sortBy (\br -> br.date |> posixToMillis)
        |> List.reverse
        |> List.map (toLogEntry now)



-- Message


type Msg
    = RequestBlocked BlockedRequestJson
    | Tick Posix



-- Init


type alias Flags =
    { blockedRequests : List BlockedRequestJson
    , currently : Int
    }


init : Flags -> ( Model, Cmd msg )
init flags =
    let
        requests =
            flags.blockedRequests |> List.map toBlockedRequest

        now =
            flags.currently |> millisToPosix

        model =
            { blockedRequests = requests
            , currently = now
            }
    in
    ( model, Cmd.none )



-- Update


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        RequestBlocked json ->
            let
                requests =
                    model.blockedRequests ++ [ toBlockedRequest json ]
            in
            ( { model | blockedRequests = requests }, Cmd.none )

        Tick time ->
            ( { model | currently = time }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ requestBlocked RequestBlocked
        , every 1000 Tick
        ]



-- View


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


viewLogEntry : LogEntry -> Html Msg
viewLogEntry request =
    div [ class "blocked-request" ] [ text request.url ]


viewRequestRange : Recency -> List LogEntry -> Html Msg
viewRequestRange recency entries =
    let
        name =
            case recency of
                Current ->
                    "Last minute"

                Recent ->
                    "Last 15 minutes"

                Old ->
                    "Older than 15 minutes"

        content =
            case entries of
                [] ->
                    [ i [] [ text "none" ] ]

                _ ->
                    List.map viewLogEntry entries
    in
    div []
        [ h3 [] [ text name ]
        , div [] content
        ]


viewLog : Model -> Html Msg
viewLog model =
    let
        entries =
            model.blockedRequests
                |> toLogEntries model.currently

        current =
            entries
                |> List.filter (\r -> r.recency == Current)

        recent =
            entries
                |> List.filter (\r -> r.recency == Recent)

        old =
            entries
                |> List.filter (\r -> r.recency == Old)
    in
    div []
        [ h2 [] [ text "Log" ]
        , viewRequestRange Current current
        , viewRequestRange Recent recent
        , viewRequestRange Old old
        ]


view : Model -> Html Msg
view model =
    div []
        [ viewSummary model
        , viewLog model
        ]



-- Main


main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }
