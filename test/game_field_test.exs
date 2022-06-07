defmodule GameFieldTest do
  use ExUnit.Case
  doctest GameField

  test "Generate default field" do
    assert GameField.generate_game_field(%GameSettings{board_size: 2, mines_quantity: 1}) == [
             %FieldCell{
               coordinate: %Coordinate{x: 1, y: 1},
               mines_around: 0,
               status: :closed,
               has_mine: false
             },
             %FieldCell{
               coordinate: %Coordinate{x: 1, y: 2},
               mines_around: 0,
               status: :closed,
               has_mine: false
             },
             %FieldCell{
               coordinate: %Coordinate{x: 2, y: 1},
               mines_around: 0,
               status: :closed,
               has_mine: false
             },
             %FieldCell{
               coordinate: %Coordinate{x: 2, y: 2},
               mines_around: 0,
               status: :closed,
               has_mine: false
             }
           ]
  end

  test "Randomly fill game field with bombs. Also fill cells with bombs around numbers" do
    Agent.start_link(fn -> %GameSettings{board_size: 2, mines_quantity: 1} end,
      name: :game_settings
    )

    Agent.start_link(
      fn ->
        [
          %FieldCell{coordinate: %Coordinate{x: 1, y: 1}},
          %FieldCell{coordinate: %Coordinate{x: 1, y: 2}}
        ]
      end,
      name: :game_field
    )

    filled_field = [
      %FieldCell{
        coordinate: %Coordinate{x: 1, y: 1},
        mines_around: 1,
        status: :closed,
        has_mine: false
      },
      %FieldCell{
        coordinate: %Coordinate{x: 1, y: 2},
        mines_around: 0,
        status: :closed,
        has_mine: true
      }
    ]

    assert GameField.fill_game_field(%Coordinate{x: 1, y: 1}) == filled_field
    assert Agent.get(:game_field, & &1) == filled_field
  end

  test "Open cell of field by coordinate" do
    assert GameField.open_cell(
             [
               %FieldCell{status: :closed, coordinate: %Coordinate{x: 1, y: 1}},
               %FieldCell{status: :closed, coordinate: %Coordinate{x: 1, y: 2}}
             ],
             %Coordinate{x: 1, y: 1}
           ) == [
             %FieldCell{status: :open, coordinate: %Coordinate{x: 1, y: 1}},
             %FieldCell{status: :closed, coordinate: %Coordinate{x: 1, y: 2}}
           ]
  end
end
