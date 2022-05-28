defmodule MinesTest do
  use ExUnit.Case
  doctest Mines

  describe "Testing game board" do
    test "Generate field with random mines but without mine on input coords" do
      assert Enum.count(
               Mines.generate_field(%Coordinate{x: 1, y: 1}, %GameSettings{
                 board_size: 3,
                 mines_quantity: 3
               })
             ) == 9
    end
  end

  describe "Testing left_click" do
    test "Left click with valid coordinates should return :ok" do
      assert Mines.left_click(2, 4) == {:ok, "Result."}
    end

    test "Left click with invalid coordinates should return :err" do
      assert Mines.left_click(22, 4) == {:err, "Invalid input."}
    end
  end
end
