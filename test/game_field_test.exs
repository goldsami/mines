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

  describe "Test game field filling" do
    test "Randomly fill game field with mines. Also fill cells with mines around numbers" do
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
  end

  describe "Cell opening" do
    test "Open cell of field by coordinate" do
      Agent.start_link(fn -> [] end, name: :game_field)
      Agent.start_link(fn -> %GameSettings{board_size: 2} end, name: :game_settings)

      expected_res = [
        %FieldCell{status: :open, mines_around: 1, coordinate: %Coordinate{x: 1, y: 1}},
        %FieldCell{status: :closed, has_mine: true, coordinate: %Coordinate{x: 1, y: 2}}
      ]

      assert GameField.open_cell(
               [
                 %FieldCell{
                   status: :closed,
                   mines_around: 1,
                   coordinate: %Coordinate{x: 1, y: 1}
                 },
                 %FieldCell{status: :closed, has_mine: true, coordinate: %Coordinate{x: 1, y: 2}}
               ],
               %Coordinate{x: 1, y: 1}
             ) == expected_res

      assert Agent.get(:game_field, & &1) == expected_res
    end

    test "Opening cell without mines around should open neighbor cells too recursively" do
      Agent.start_link(fn -> [] end, name: :game_field)
      Agent.start_link(fn -> %GameSettings{board_size: 3} end, name: :game_settings)

      start_field = [
        %FieldCell{status: :closed, mines_around: 0, coordinate: %Coordinate{x: 1, y: 1}},
        %FieldCell{status: :closed, mines_around: 0, coordinate: %Coordinate{x: 1, y: 2}},
        %FieldCell{status: :closed, mines_around: 1, coordinate: %Coordinate{x: 1, y: 3}},
        %FieldCell{status: :closed, has_mine: true, coordinate: %Coordinate{x: 1, y: 4}}
      ]

      expected_res = [
        %FieldCell{status: :open, mines_around: 0, coordinate: %Coordinate{x: 1, y: 1}},
        %FieldCell{status: :open, mines_around: 0, coordinate: %Coordinate{x: 1, y: 2}},
        %FieldCell{status: :open, mines_around: 1, coordinate: %Coordinate{x: 1, y: 3}},
        %FieldCell{status: :closed, has_mine: true, coordinate: %Coordinate{x: 1, y: 4}}
      ]

      assert GameField.open_cell(start_field, %Coordinate{x: 1, y: 1}) == expected_res
      assert Agent.get(:game_field, & &1) == expected_res
    end

    test "Open invalid cell should return an error" do
      Agent.start_link(fn -> %GameSettings{board_size: 2} end, name: :game_settings)

      assert GameField.open_cell([], %Coordinate{x: 10, y: 1}) == {:err, "Invalid coordinate."}
    end
  end

  describe "Mark cell with flag" do
    test "Set flag to cell by coordinate" do
      Agent.start_link(fn -> [] end, name: :game_field)
      Agent.start_link(fn -> %GameSettings{board_size: 2} end, name: :game_settings)

      expected_res = [
        %FieldCell{status: :flag, coordinate: %Coordinate{x: 1, y: 1}},
        %FieldCell{status: :closed, coordinate: %Coordinate{x: 1, y: 2}}
      ]

      assert GameField.flag_cell(
               [
                 %FieldCell{status: :closed, coordinate: %Coordinate{x: 1, y: 1}},
                 %FieldCell{status: :closed, coordinate: %Coordinate{x: 1, y: 2}}
               ],
               %Coordinate{x: 1, y: 1}
             ) == expected_res

      assert Agent.get(:game_field, & &1) == expected_res
    end

    test "Set flag to opened cell should do nothing" do
      Agent.start_link(fn -> %GameSettings{board_size: 2} end, name: :game_settings)

      game_field = [
        %FieldCell{status: :open, coordinate: %Coordinate{x: 1, y: 1}},
        %FieldCell{status: :closed, coordinate: %Coordinate{x: 1, y: 2}}
      ]

      assert GameField.flag_cell(game_field, %Coordinate{x: 1, y: 1}) == game_field
    end

    test "Set flag to invalid cell should return an error" do
      Agent.start_link(fn -> %GameSettings{board_size: 2} end, name: :game_settings)

      assert GameField.flag_cell([], %Coordinate{x: 10, y: 1}) == {:err, "Invalid coordinate."}
    end
  end

  describe "Get opened field" do
    test "Should return game field with all cells opened" do
      GameField.get_opened_field([
        %FieldCell{status: :open, coordinate: %Coordinate{x: 1, y: 1}},
        %FieldCell{status: :closed, coordinate: %Coordinate{x: 1, y: 2}},
        %FieldCell{status: :closed, coordinate: %Coordinate{x: 1, y: 3}}
      ]) == [
        %FieldCell{status: :open, coordinate: %Coordinate{x: 1, y: 1}},
        %FieldCell{status: :open, coordinate: %Coordinate{x: 1, y: 2}},
        %FieldCell{status: :open, coordinate: %Coordinate{x: 1, y: 3}}
      ]
    end
  end
end
