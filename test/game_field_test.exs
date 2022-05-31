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

  test "Write field to store" do
    {:ok, pid} =
      GameField.write_game_field_to_store([
        %FieldCell{
          coordinate: %Coordinate{x: 1, y: 1}
        }
      ])

    assert Agent.get(pid, fn state -> state end) == [
             %FieldCell{
               coordinate: %Coordinate{x: 1, y: 1}
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

    GameField.fill_game_field(%Coordinate{x: 1, y: 1})

    assert Agent.get(:game_field, & &1) == [
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
  end

  test "Clears game field from store" do
    Agent.start_link(fn -> [] end, name: :game_field)
    GameField.crear_game_field()

    assert Process.whereis(:game_field) == nil
  end
end
