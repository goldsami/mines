defmodule Mines do
  @moduledoc """
  Documentation for `Mines`.
  """

  @doc """
  Creates game field and writes it to Agent. Also writes GameSettings to Agent

  ## Examples
      iex> Mines.init_game(%GameSettings{board_size: 3, mines_quantity: 3})
      {:ok}
  """
  def init_game(game_settings \\ %GameSettings{}) do
    write_settings_to_store(game_settings)
    generate_game_field(game_settings) |> write_game_field_to_store()
    {:ok}
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
  def left_click(coordinate, game_settings \\ %GameSettings{})

  def left_click(coordinate, game_settings)
      when coordinate.x in 1..game_settings.board_size and
             coordinate.y in 1..game_settings.board_size do
    {:ok, "Result."}
  end

  def left_click(_, _), do: {:err, "Invalid input."}

  defp write_settings_to_store(game_settings) do
    Agent.start_link(fn -> game_settings end, name: :game_settings)
  end

  defp write_game_field_to_store(game_field) do
    Agent.start_link(fn -> game_field end, name: :game_field)
  end

  defp generate_game_field(game_settings) do
    cells =
      for x <- 1..game_settings.mines_quantity,
          do:
            for(
              y <- 1..game_settings.mines_quantity,
              do: %FieldCell{coordinate: %Coordinate{x: x, y: y}}
            )

    List.flatten(cells)
  end

  defp fill_game_field(ignore_cell) do
    # get_game_field()
    # TODO
  end

  defp get_game_field() do
    Agent.get(:game_field, & &1)
  end

  defp get_game_settings() do
    Agent.get(:game_settings, & &1)
  end
end
