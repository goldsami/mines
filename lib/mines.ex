defmodule Mines do
  @moduledoc """
  Documentation for `Mines`.
  """

  @doc """
  Generates field with mines

  ## Examples
      iex> Mines.generate_field(%Coordinate{x: 1, y: 1}, %GameSettings{board_size: 3, mines_quantity: 3})
      [
        {1, 1}, {1, 2}, {1, 3},
        {2, 1}, {2, 2}, {2, 3},
        {3, 1}, {3, 2}, {3, 3}
      ]
  """
  def generate_field(_ignore_field_coords, game_settings) do
    cells =
      for x <- 1..game_settings.mines_quantity,
          do: for(y <- 1..game_settings.mines_quantity, do: {x, y})

    List.flatten(cells)
  end

  @doc """
  Left click on field. Coordinates should be in range from 1 to @board_size

  ## Examples
      iex> Mines.left_click(%Coordinate{x: 2, y: 3})
      {:ok, "Result."}

      iex> Mines.left_click(%Coordinate{x: 1, y: 44})
      {:err, "Invalid input."}

      iex> Mines.left_click(%Coordinate{x: 11, y: 4})
      {:err, "Invalid input."}
  """
  def left_click(coordinate) when coordinate.x in 1..8 and coordinate.y in 1..8 do
    {:ok, "Result."}
  end

  def left_click(_), do: {:err, "Invalid input."}
end
