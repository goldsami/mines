defmodule MinesTest do
  use ExUnit.Case
  doctest Mines

  describe "Testing game init" do
    test "Write settings to agent" do
      Mines.init_game(%GameSettings{board_size: 2, mines_quantity: 2})
      assert Agent.get(:game_settings, & &1) == %GameSettings{board_size: 2, mines_quantity: 2}
    end

    test "Generate default field" do
      generated_field = [
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

      assert Mines.init_game(%GameSettings{board_size: 2, mines_quantity: 2}) == generated_field

      assert Agent.get(:game_field, & &1) == generated_field
    end
  end

  describe "Testing left_click" do
    test "Left click with valid coordinates should return :ok" do
      assert Mines.left_click(%Coordinate{x: 2, y: 1}) == {:ok}
    end

    test "Left click with invalid coordinates should return :err" do
      assert Mines.left_click(%Coordinate{x: 10, y: 1}) == {:err, "Invalid input."}
    end
  end
end
