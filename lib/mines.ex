defmodule Mines do
  @moduledoc """
  Documentation for `Mines`.
  """

  @doc """
  Creates game field and writes it to the store. Also writes GameSettings to the store.
  Should be called before each game.

  ## Examples
      iex> Mines.init_game(%GameSettings{board_size: 1, mines_quantity: 0})
      [%FieldCell{coordinate: %Coordinate{x: 1, y: 1}}]
      iex> Agent.get(:game_settings, fn state -> state end)
      %GameSettings{board_size: 1, mines_quantity: 0}
      iex> Agent.get(:game_field, fn state -> state end)
      [%FieldCell{coordinate: %Coordinate{x: 1, y: 1}}]
      iex> Agent.get(:game_state, fn state -> state end)
      %GameState{is_initialized: true}

  """
  def init_game(game_settings \\ %GameSettings{}) do
    Agent.start_link(fn -> game_settings end, name: :game_settings)
    Agent.start_link(fn -> %GameState{is_initialized: true} end, name: :game_state)
    game_field = GameField.generate_game_field(game_settings)
    Agent.start_link(fn -> game_field end, name: :game_field)
    game_field
  end

  @doc """
  Starts game by clicking on first cell. Should be called after game init.

  ## Examples
      iex> Agent.start_link(fn -> %GameSettings{board_size: 2, mines_quantity: 1} end, name: :game_settings)
      iex> Agent.start_link(fn -> %GameState{is_initialized: true} end, name: :game_state)
      iex> Agent.start_link(fn -> [%FieldCell{coordinate: %Coordinate{x: 1, y: 1}}, %FieldCell{coordinate: %Coordinate{x: 1, y: 2}}] end, name: :game_field)
      iex> Mines.start_game(%Coordinate{x: 1, y: 1})
      [%FieldCell{coordinate: %Coordinate{x: 1, y: 1}, mines_around: 1, status: :open}, %FieldCell{coordinate: %Coordinate{x: 1, y: 2}, has_mine: true}]
  """
  def start_game(first_coord) do
    GameField.fill_game_field(first_coord)
    |> GameField.open_cell(first_coord)
  end

  @doc """
  Clears game field and settings

  ## Examples
      iex> Agent.start_link(fn -> %GameSettings{} end, name: :game_settings)
      iex> Agent.start_link(fn -> %GameState{} end, name: :game_state)
      iex> Agent.start_link(fn -> [] end, name: :game_field)
      iex> Mines.finish_game()
      :ok
      iex> Process.whereis(:game_settings)
      nil
      iex> Process.whereis(:game_field)
      nil
      iex> Process.whereis(:game_state)
      nil
  """
  def finish_game() do
    Agent.stop(:game_field)
    Agent.stop(:game_settings)
    Agent.stop(:game_state)
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
