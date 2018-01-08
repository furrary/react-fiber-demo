module FiberDemo exposing (..)

import AnimationFrame
import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Html.Events exposing (onMouseEnter, onMouseLeave)
import Html.Lazy as Lazy
import Time exposing (Time)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL --


type alias Model =
    { elapsedSecond : Time
    , hoveredDotPosition : Maybe Position
    }


init : ( Model, Cmd Msg )
init =
    ( { elapsedSecond = 0
      , hoveredDotPosition = Nothing
      }
    , Cmd.none
    )


type alias Position =
    ( Float, Float )


targetSize : Float
targetSize =
    25



-- UPDATE --


type Msg
    = AddElapsedTime Time
    | HoverDot Position
    | UnHoverDot


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddElapsedTime time ->
            ( { model | elapsedSecond = model.elapsedSecond + Time.inSeconds time }, Cmd.none )

        HoverDot position ->
            ( { model | hoveredDotPosition = Just position }, Cmd.none )

        UnHoverDot ->
            ( { model | hoveredDotPosition = Nothing }, Cmd.none )



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions _ =
    AnimationFrame.diffs AddElapsedTime



-- VIEW --


view : Model -> Html Msg
view model =
    let
        remainder =
            fmod model.elapsedSecond 10

        scaleXFactor =
            (1 + (5 - abs (5 - remainder)) / 10) / 2.1

        transformFunction =
            "scaleX(" ++ toString scaleXFactor ++ ") scaleY(0.7) translateZ(0.1px)"
    in
    div
        [ style
            [ ( "position", "absolute" )
            , ( "left", "50%" )
            , ( "top", "50%" )
            , ( "width", "10px" )
            , ( "height", "10px" )
            , ( "background", "#eee" )
            , ( "transformOrigin", "0 0" )
            , ( "transform", transformFunction )
            ]
        ]
        [ Lazy.lazy2 viewWrappedTriangle model.hoveredDotPosition << toString <| floor remainder
        ]


viewWrappedTriangle : Maybe Position -> String -> Html Msg
viewWrappedTriangle hoveredDotPosition text =
    div [] <| viewTriangle hoveredDotPosition text 1000 ( 0, 0 )


viewTriangle : Maybe Position -> String -> Float -> Position -> List (Html Msg)
viewTriangle hoveredDotPosition text size ( x, y ) =
    if size <= targetSize then
        [ viewDot hoveredDotPosition text ( x - targetSize / 2, y - targetSize / 2 ) ]
    else
        let
            newSize =
                size / 2

            viewTriangle_ =
                viewTriangle hoveredDotPosition text newSize
        in
        viewTriangle_ ( x, y - newSize / 2 )
            ++ viewTriangle_ ( x - newSize, y + newSize / 2 )
            ++ viewTriangle_ ( x + newSize, y + newSize / 2 )


viewDot : Maybe Position -> String -> Position -> Html Msg
viewDot hoveredDotPosition text ( x, y ) =
    let
        isHovered =
            hoveredDotPosition == Just ( x, y )

        dotSize =
            targetSize * 1.3
    in
    div
        [ style
            [ ( "position", "absolute" )
            , ( "left", px x )
            , ( "top", px y )
            , ( "width", px dotSize )
            , ( "height", px dotSize )
            , ( "border-radius", "50%" )
            , ( "background"
              , if isHovered then
                    "#ff0"
                else
                    "#61dafb"
              )
            , ( "font", "normal 15px sans-serif" )
            , ( "textAlign", "center" )
            , ( "cursor", "pointer" )
            , ( "lineHeight", px dotSize )
            ]
        , onMouseEnter <| HoverDot ( x, y )
        , onMouseLeave UnHoverDot
        ]
        [ Html.text
            (if isHovered then
                "*" ++ text ++ "*"
             else
                text
            )
        ]



-- INTERNAL --


px : number -> String
px =
    toString >> flip (++) "px"


fmod : Float -> Int -> Float
fmod a b =
    a - toFloat (floor a) + toFloat (floor a % b)
