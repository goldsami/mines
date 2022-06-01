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
               %FieldCell{coordinate: %Coordinate{x: 1, y: 1}, mines_around: 1},
               %FieldCell{coordinate: %Coordinate{x: 1, y: 2}, has_mine: true}
             ]
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
