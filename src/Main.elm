module Main exposing (Model, Msg(..), main, update, view)

import Browser
import Html exposing (Html, div)
import Html.Attributes
import Html.Events.Extra.Pointer as Pointer


type alias Model =
    Card


type alias Card =
    { position :
        { x : Float
        , y : Float
        }
    , state : CardState
    , content : String
    , cardOffset :
        Maybe
            -- @todo extract Position type?
            { x : Float
            , y : Float
            }
    }


type CardState
    = Free
    | InHand


initModel : Card
initModel =
    { position = { x = 0, y = 0 }
    , state = Free
    , content = "Hello x"
    , cardOffset = Nothing
    }


type Msg
    = PointerDownMsg ( Float, Float )
    | PointerUpMsg
    | PointerMoveMsg ( Float, Float )


pickupCard : Float -> Float -> Card -> Card
pickupCard x y card =
    { card
        | state = InHand
        , cardOffset = Just { x = x, y = y }
    }


dropCard : Card -> Card
dropCard card =
    { card
        | state = Free
    }


moveCard : Float -> Float -> (Card -> Card)
moveCard mx my card =
    let
        offset =
            Maybe.withDefault { x = 0, y = 0 } card.cardOffset

        newX =
            mx - offset.x

        newY =
            my - offset.y
    in
    case card.state of
        InHand ->
            { card | position = { x = newX, y = newY } }

        Free ->
            card


update : Msg -> Model -> Model
update msg model =
    case msg of
        PointerDownMsg ( x, y ) ->
            pickupCard x y model

        PointerUpMsg ->
            dropCard model

        PointerMoveMsg ( newX, newY ) ->
            moveCard newX newY model


viewCard : Card -> Html Msg
viewCard card =
    div
        [ Html.Attributes.style "position"
            "absolute"
        , Html.Attributes.style
            "top"
            (String.fromFloat card.position.y ++ "px")
        , Html.Attributes.style
            "left"
            (String.fromFloat card.position.x ++ "px")
        , Html.Attributes.style
            "background-color"
            "lightgrey"
        , Html.Attributes.style
            "padding"
            "1ex"
        , Html.Attributes.style
            "border"
            "1px solid black"
        , Html.Attributes.style
            "border-radius"
            "5px"
        , Pointer.onDown (\event -> PointerDownMsg event.pointer.offsetPos)
        ]
        [ Html.text card.content
        ]


view : Model -> Html Msg
view model =
    let
        cards =
            [ model ]
    in
    div
        [ Html.Attributes.style "width" "100vw"
        , Html.Attributes.style "height" "100vh"
        , Pointer.onMove (\event -> PointerMoveMsg event.pointer.pagePos)
        , Pointer.onUp (always PointerUpMsg)
        ]
        (List.map viewCard cards)


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initModel
        , view = view
        , update = update
        }
