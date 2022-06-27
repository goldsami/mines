defmodule MinesConsoleGame do
  @moduledoc """
  Console adapter for Mines game.
  """

  def start_game() do
    game_settings = %GameSettings{}

    Mines.init_game(game_settings)
    |> print_game_field(game_settings)

    {x, _} = IO.gets("enter x: ") |> Integer.parse()
    {y, _} = IO.gets("enter y: ") |> Integer.parse()

    Mines.start_game(%Coordinate{x: x, y: y})
    |> print_game_field(game_settings)
  end

  defp print_game_field(game_field, game_settings) do
    IO.write("  ")
    for n <- 1..game_settings.board_size, do: IO.write(" #{n}")

    for y <- 1..game_settings.board_size do
      IO.write("\n#{y} ")

      for(
        x <- 1..game_settings.board_size,
        do: find_cell_by_coord(game_field, %Coordinate{x: x, y: y}) |> write_cell_to_console
      )
    end

    IO.write("\n")
  end

  defp find_cell_by_coord(game_field, coord) do
    Enum.find(game_field, fn cell ->
      cell.coordinate.x == coord.x && cell.coordinate.y == coord.y
    end)
  end

  defp write_cell_to_console(cell) do
    cond do
      cell.status == :closed -> " #"
      cell.has_mine -> " *"
      true -> " #{cell.mines_around}"
    end
    |> IO.write()
  end
end
