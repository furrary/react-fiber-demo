module ReactFiber exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onMouseEnter, onMouseLeave)
import Task
import Time exposing (Time)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { startTime : Time
    , currentTime : Time
    , hoveredNode : Maybe ( Float, Float )
    }


type Msg
    = SetStartTime Time
    | SetCurrentTime Time
    | Hover ( Float, Float )
    | UnHover


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetStartTime time ->
            update (SetCurrentTime time) { model | startTime = model.startTime }

        SetCurrentTime time ->
            ( { model | currentTime = time }, Cmd.none )

        Hover ( x, y ) ->
            ( { model | hoveredNode = Just ( x, y ) }, Cmd.none )

        UnHover ->
            ( { model | hoveredNode = Nothing }, Cmd.none )


targetSize : Float
targetSize =
    25


containerStyleList : List ( String, String )
containerStyleList =
    [ ( "position", "absolute" )
    , ( "transformOrigin", "0 0" )
    , ( "left", "50%" )
    , ( "top", "50%" )
    , ( "width", "10px" )
    , ( "height", "10px" )
    , ( "background", "#eee" )
    ]


view : Model -> Html Msg
view model =
    let
        elapsedTime =
            Time.inSeconds model.currentTime - model.startTime

        remainder =
            elapsedTime
                - (floor elapsedTime
                    // 10
                    * 10
                    |> toFloat
                  )

        scale =
            1
                + (if remainder > 5 then
                    10 - remainder
                   else
                    remainder
                  )
                / 10

        transform =
            "scaleX(" ++ toString (scale / 2.1) ++ ") scaleY(0.7) translateZ(0.1px)"
    in
    div [ style <| ( "transform", transform ) :: containerStyleList ]
        [ div [] <| sierpinskiTriangle model.hoveredNode 0 0 1000 <| toString <| floor remainder
        ]


dotStyleList : List ( String, String )
dotStyleList =
    [ ( "position", "absolute" )
    , ( "font", "normal 15px sans-serif" )
    , ( "textAlign", "center" )
    , ( "cursor", "pointer" )
    ]


dot : Bool -> ( Float, Float ) -> String -> Html Msg
dot isHovered ( x, y ) text =
    let
        size =
            targetSize * 1.3
    in
    div
        [ style
            (dotStyleList
                ++ [ ( "width", toString size ++ "px" )
                   , ( "height", toString size ++ "px" )
                   , ( "left", toString x ++ "px" )
                   , ( "top", toString y ++ "px" )
                   , ( "border-radius", "50%" )
                   , ( "lineHeight", toString size ++ "px" )
                   , ( "background"
                     , if isHovered then
                        "#ff0"
                       else
                        "#61dafb"
                     )
                   ]
            )
        , onMouseEnter <| Hover ( x, y )
        , onMouseLeave UnHover
        ]
        [ Html.text
            (if isHovered then
                "*" ++ text ++ "*"
             else
                text
            )
        ]


sierpinskiTriangle : Maybe ( Float, Float ) -> Float -> Float -> Float -> String -> List (Html Msg)
sierpinskiTriangle hoveredNode x y size text =
    if size <= targetSize then
        let
            coord =
                ( x - targetSize / 2, y - targetSize / 2 )
        in
        [ dot (hoveredNode == Just coord) coord text ]
    else
        let
            newSize =
                size / 2
        in
        sierpinskiTriangle hoveredNode x (y - newSize / 2) newSize text
            ++ sierpinskiTriangle hoveredNode (x - newSize) (y + newSize / 2) newSize text
            ++ sierpinskiTriangle hoveredNode (x + newSize) (y + newSize / 2) newSize text


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        fps =
            60
    in
    Time.every (Time.second / fps) SetCurrentTime


init : ( Model, Cmd Msg )
init =
    ( { startTime = 0
      , currentTime = 0
      , hoveredNode = Nothing
      }
    , Task.perform SetStartTime Time.now
    )
