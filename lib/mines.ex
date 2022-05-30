defmodule Mines do
  @moduledoc """
  Documentation for `Mines`.
  """

  @doc """
  Creates game field and writes it to Agent. Also writes GameSettings to Agent

  ## Examples
      iex> Mines.init_game(%GameSettings{board_size: 1, mines_quantity: 0})
      {:ok}
      iex> Agent.get(:game_settings, fn state -> state end)
      %GameSettings{board_size: 1, mines_quantity: 0}
      iex> Agent.get(:game_field, fn state -> state end)
      [%FieldCell{coordinate: %Coordinate{x: 1, y: 1}}]

  """
  def init_game(game_settings \\ %GameSettings{}) do
    GameSettings.write_settings_to_store(game_settings)
    GameField.generate_game_field(game_settings) |> GameField.write_game_field_to_store()
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
end
