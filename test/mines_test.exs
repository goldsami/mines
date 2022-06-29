defmodule MinesTest do
  use ExUnit.Case
  doctest Mines

  describe "Testing game init" do
    test "Write settings to agent" do
      Mines.init_game(%GameSettings{board_size: 2, mines_quantity: 2})
      assert Agent.get(:game_settings, & &1) == %GameSettings{board_size: 2, mines_quantity: 2}
    end

    test "Write game state to agent" do
      Mines.init_game()

      assert Agent.get(:game_state, & &1) == %GameState{
               is_initialized: true,
               game_started: false
             }
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

  describe "Testing game reseting" do
    test "Clears settings, game state and game field from store" do
      Agent.start_link(fn -> %GameSettings{} end, name: :game_settings)
      Agent.start_link(fn -> [] end, name: :game_field)
      Agent.start_link(fn -> %GameState{} end, name: :game_state)
      Mines.finish_game()

      assert Process.whereis(:game_settings) == nil
      assert Process.whereis(:game_field) == nil
      assert Process.whereis(:game_state) == nil
    end
  end

  describe "Testing game start" do
    test "Game start should fill cells with bombs and mines around number" do
      Agent.start_link(fn -> %GameSettings{board_size: 2, mines_quantity: 1} end,
        name: :game_settings
      )

      Agent.start_link(fn -> %GameState{is_initialized: true} end, name: :game_state)

      Agent.start_link(
        fn ->
          [
            %FieldCell{coordinate: %Coordinate{x: 1, y: 1}},
            %FieldCell{coordinate: %Coordinate{x: 1, y: 2}}
          ]
        end,
        name: :game_field
      )

      assert Mines.start_game(%Coordinate{x: 1, y: 1}) == [
               %FieldCell{coordinate: %Coordinate{x: 1, y: 1}, mines_around: 1, status: :open},
               %FieldCell{coordinate: %Coordinate{x: 1, y: 2}, has_mine: true}
             ]
    end
  end

  describe "Testing left_click" do
    test "Left click on cell without mine should open that cell" do
      Agent.start_link(fn -> %GameSettings{} end, name: :game_settings)

      game_field = [
        %FieldCell{coordinate: %Coordinate{x: 1, y: 1}},
        %FieldCell{coordinate: %Coordinate{x: 1, y: 2}, mines_around: 1},
        %FieldCell{coordinate: %Coordinate{x: 1, y: 3}, has_mine: true}
      ]

      updated_game_field = [
        %FieldCell{coordinate: %Coordinate{x: 1, y: 1}},
        %FieldCell{coordinate: %Coordinate{x: 1, y: 2}, mines_around: 1, status: :open},
        %FieldCell{coordinate: %Coordinate{x: 1, y: 3}, has_mine: true}
      ]

      Agent.start_link(fn -> game_field end, name: :game_field)

      assert Mines.left_click(game_field, %Coordinate{x: 1, y: 2}) == updated_game_field

      assert Agent.get(:game_field, & &1) == updated_game_field
    end

    test "Left click on mine should return :loose" do
      Agent.start_link(fn -> %GameSettings{} end, name: :game_settings)
      Agent.start_link(fn -> %GameState{} end, name: :game_state)

      game_field = [
        %FieldCell{coordinate: %Coordinate{x: 1, y: 1}, status: :open},
        %FieldCell{coordinate: %Coordinate{x: 1, y: 2}, mines_around: 1},
        %FieldCell{coordinate: %Coordinate{x: 1, y: 3}, has_mine: true}
      ]

      Agent.start_link(fn -> game_field end, name: :game_field)

      assert Mines.left_click(game_field, %Coordinate{x: 1, y: 3}) == :loose

      assert Process.whereis(:game_settings) == nil
      assert Process.whereis(:game_field) == nil
      assert Process.whereis(:game_state) == nil
    end

    test "Left click on valid place when it's last non-mine cell should return :win" do
      Agent.start_link(fn -> %GameSettings{} end, name: :game_settings)
      Agent.start_link(fn -> %GameState{} end, name: :game_state)

      game_field = [
        %FieldCell{coordinate: %Coordinate{x: 1, y: 1}},
        %FieldCell{coordinate: %Coordinate{x: 1, y: 2}, status: :open},
        %FieldCell{coordinate: %Coordinate{x: 1, y: 3}, has_mine: true}
      ]

      Agent.start_link(fn -> game_field end, name: :game_field)

      assert Mines.left_click(game_field, %Coordinate{x: 1, y: 1}) == :win

      assert Process.whereis(:game_settings) == nil
      assert Process.whereis(:game_field) == nil
      assert Process.whereis(:game_state) == nil
    end

    test "Left click with invalid coordinates should throw an exception" do
      Agent.start_link(fn -> %GameSettings{} end, name: :game_settings)
      assert Mines.left_click([], %Coordinate{x: 10, y: 1}) == {:err, "Invalid input."}
    end
  end

  describe "Testing win condition" do
    test "Game field with all non-mines cells open and all mines cells closed returns true" do
      assert Mines.is_win?([
               %FieldCell{coordinate: %Coordinate{x: 1, y: 1}, status: :open},
               %FieldCell{coordinate: %Coordinate{x: 1, y: 2}, status: :open},
               %FieldCell{coordinate: %Coordinate{x: 1, y: 3}, has_mine: true}
             ]) == {:ok, true}
    end

    test "Game field with some closed non-mines cells returns false" do
      assert Mines.is_win?([
               %FieldCell{coordinate: %Coordinate{x: 1, y: 1}, status: :open},
               %FieldCell{coordinate: %Coordinate{x: 1, y: 2}},
               %FieldCell{coordinate: %Coordinate{x: 1, y: 3}, has_mine: true}
             ]) == {:ok, false}
    end

    test "Empty game field should return an error" do
      assert Mines.is_win?([]) == {:err, "Game field is empty."}
    end
  end

  describe "Testing is_mine? fn" do
    test "Call with empty game field should return false" do
      assert Mines.is_mine?([], %Coordinate{x: 1, y: 1}) == false
    end

    test "Call with coordinate which is not present on game field should return false" do
      assert Mines.is_mine?(
               [
                 %FieldCell{coordinate: %Coordinate{x: 1, y: 1}},
                 %FieldCell{coordinate: %Coordinate{x: 1, y: 2}, has_mine: true}
               ],
               %Coordinate{x: 11, y: 11}
             ) == false
    end

    test "Checking cell without mine should return false" do
      assert Mines.is_mine?(
               [
                 %FieldCell{coordinate: %Coordinate{x: 1, y: 1}},
                 %FieldCell{coordinate: %Coordinate{x: 1, y: 2}, has_mine: true}
               ],
               %Coordinate{x: 1, y: 1}
             ) == false
    end

    test "Checking cell with mine should return true" do
      assert Mines.is_mine?(
               [
                 %FieldCell{coordinate: %Coordinate{x: 1, y: 1}},
                 %FieldCell{coordinate: %Coordinate{x: 1, y: 2}, has_mine: true}
               ],
               %Coordinate{x: 1, y: 2}
             ) == true
    end
  end

  describe "Testing coordinate validation" do
    test "Valid coordinate validation should return :ok" do
      Agent.start_link(fn -> %GameSettings{board_size: 2} end, name: :game_settings)

      assert Mines.validate_coord(%Coordinate{x: 1, y: 1}) == :ok
    end

    test "Invalid coordinate validation should throw an exception" do
      Agent.start_link(fn -> %GameSettings{board_size: 2} end, name: :game_settings)

      assert Mines.validate_coord(%Coordinate{x: 10, y: 1}) == {:err, "Invalid input."}
    end
  end
end
