module Main exposing (main)

import Browser
import Html exposing (Html, button, div, input, li, text, ul)
import Html.Attributes exposing (placeholder, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode



-----------------
-- MODEL
-- This type describes the entire application state (model)
-- Similar to useState or Redux store in other frameworks


type alias Model =
    { inputText : String -- Text from the input field
    , todos : List String -- List of steps returned by the AI
    , isLoading : Bool -- Whether to show the loading indicator
    , error : Maybe String -- Error message, if any
    }



-- Initial application state


init : Model
init =
    { inputText = ""
    , todos = []
    , isLoading = False
    , error = Nothing
    }



-----------------
-- MSG
-- All possible messages (events) that can occur in the app
-- Similar to Redux actions


type Msg
    = UpdateInput String -- User updated the input text
    | GenerateTodos -- Button "Generate steps" was clicked
    | ReceiveTodos (Result Http.Error (List String)) -- Response from the server (success or error)



-----------------
-- UPDATE
-- Reducer: handles messages and updates the model. Returns new model + command (if any)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- Update inputText in the model
        UpdateInput newText ->
            ( { model | inputText = newText }, Cmd.none )

        -- User clicked the button: set loading to true and send HTTP request
        GenerateTodos ->
            ( { model | isLoading = True, error = Nothing }
            , sendToAi model.inputText
            )

        -- Handle server response (either success or error)
        ReceiveTodos result ->
            case result of
                Ok steps ->
                    -- Successfully received list of steps
                    ( { model | todos = steps, isLoading = False }, Cmd.none )

                Err _ ->
                    -- Error occurred during request
                    ( { model | error = Just "Error while fetching steps", isLoading = False }, Cmd.none )



-----------------
-- VIEW
-- Main function to render UI based on current model


view : Model -> Html Msg
view model =
    div []
        [ input
            [ placeholder "For example: I want to make a pizza"
            , value model.inputText
            , onInput UpdateInput
            ]
            []
        , button [ onClick GenerateTodos ] [ text "Generate ToDo List =)" ]
        , viewStatus model -- Show status (loading or error)
        , viewTodos model.todos -- Show list of steps
        ]



-- Display loading message or error


viewStatus : Model -> Html msg
viewStatus model =
    if model.isLoading then
        div [] [ text "Loading..." ]

    else
        case model.error of
            Just msg ->
                div [] [ text msg ]

            Nothing ->
                text ""



-- Render a list of steps as <ul><li></li></ul>


viewTodos : List String -> Html msg
viewTodos items =
    ul [] (List.map (\item -> li [] [ text item ]) items)



-----------------
-- HTTP
-- Function to send POST request to the server with the task text


sendToAi : String -> Cmd Msg
sendToAi inputText =
    let
        body =
            Http.jsonBody (Encode.object [ ( "task", Encode.string inputText ) ])
    in
    Http.post
        { url = "http://localhost:3000/api/ai-todos"
        , body = body
        , expect = Http.expectJson ReceiveTodos stepsDecoder
        }



-- JSON decoder: expects a "steps" field with a list of strings


stepsDecoder : Decoder (List String)
stepsDecoder =
    Decode.field "steps" (Decode.list Decode.string)



-----------------
-- MAIN
-- Entry point of the Elm application


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( init, Cmd.none ) -- Initial model
        , update = update -- Logic for handling events
        , view = view -- UI rendering
        , subscriptions = \_ -> Sub.none -- No subscriptions for now (e.g., WebSocket)
        }
