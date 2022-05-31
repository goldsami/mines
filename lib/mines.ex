defmodule Mines do
  @moduledoc """
  Documentation for `Mines`.
  """

  @doc """
  Creates game field and writes it to Agent. Also writes GameSettings to Agent

  ## Examples
      iex> Mines.init_game(%GameSettings{board_size: 1, mines_quantity: 0})
      [%FieldCell{coordinate: %Coordinate{x: 1, y: 1}}]
      iex> Agent.get(:game_settings, fn state -> state end)
      %GameSettings{board_size: 1, mines_quantity: 0}
      iex> Agent.get(:game_field, fn state -> state end)
      [%FieldCell{coordinate: %Coordinate{x: 1, y: 1}}]

  """
  def init_game(game_settings \\ %GameSettings{}) do
    Agent.start_link(fn -> game_settings end, name: :game_settings)
    game_field = GameField.generate_game_field(game_settings)
    Agent.start_link(fn -> game_field end, name: :game_field)
    game_field
  end

  @doc """
  Clears game field and settings

  ## Examples
      iex> Agent.start_link(fn -> %GameSettings{} end, name: :game_settings)
      iex> Agent.start_link(fn -> [] end, name: :game_field)
      iex> Mines.finish_game()
      :ok
      iex> Process.whereis(:game_settings)
      nil
      iex> Process.whereis(:game_field)
      nil
  """
  def finish_game() do
    Agent.stop(:game_field)
    Agent.stop(:game_settings)
    :ok
  end

  @doc """
  Left click on field. Coordinates should be in range from 1 to @board_size

  ## Examples
      iex> Mines.left_click(%Coordinate{x: 2, y: 3})
      {:ok}

      iex> Mines.left_click(%Coordinate{x: 1, y: 44})
      {:err, "Invalid input."}

      iex> Mines.left_click(%Coordinate{x: 11, y: 4})
      {:err, "Invalid input."}
  """
  def left_click(coordinate, game_settings \\ %GameSettings{})

  def left_click(coordinate, game_settings)
      when coordinate.x in 1..game_settings.board_size and
             coordinate.y in 1..game_settings.board_size do
    {:ok}
  end

  def left_click(_, _), do: {:err, "Invalid input."}
end
