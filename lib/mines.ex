defmodule Mines do
  # TODO:(refactor) Use only 'coord' or 'coordination' but not both. Same for 'bomb'/'mine'
  # TODO:(feature) On cell open if it has 0 mines around - open them too
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
      iex> Agent.start_link(fn -> %GameSettings{} end, name: :game_settings)
      iex> game_field = [%FieldCell{coordinate: %Coordinate{x: 1, y: 1}}, %FieldCell{coordinate: %Coordinate{x: 1, y: 2}, mines_around: 1}, %FieldCell{coordinate: %Coordinate{x: 1, y: 3}, has_mine: true}]
      iex> Agent.start_link(fn -> game_field end, name: :game_field)
      iex> Mines.left_click(game_field, %Coordinate{x: 1, y: 2})
      [%FieldCell{coordinate: %Coordinate{x: 1, y: 1}}, %FieldCell{coordinate: %Coordinate{x: 1, y: 2}, mines_around: 1, status: :open}, %FieldCell{coordinate: %Coordinate{x: 1, y: 3}, has_mine: true} ]
  """
  def left_click(game_field, coordinate) do
    case validate_coord(coordinate) do
      {:ok, _} ->
        case is_mine?(game_field, coordinate) do
          true ->
            finish_game()
            :loose

          false ->
            new_field = GameField.open_cell(game_field, coordinate)

            case is_win?(new_field) do
              {:ok, true} ->
                finish_game()
                :win

              {:ok, false} ->
                new_field

              err ->
                err
            end
        end

      err ->
        err
    end
  end

  @doc """
  Check if player win

  ## Example
      iex> Mines.is_win?([%FieldCell{coordinate: %Coordinate{x: 1, y: 1}, status: :open}, %FieldCell{coordinate: %Coordinate{x: 1, y: 2}, status: :open}, %FieldCell{coordinate: %Coordinate{x: 1, y: 3}, has_mine: true}])
      {:ok, :true}
  """
  def is_win?([]), do: {:err, "Game field is empty."}

  def is_win?(game_field) do
    {:ok,
     Enum.filter(game_field, fn x -> !x.has_mine && x.status == :closed end) |> Enum.count() == 0}

    # Enum.filter(game_field, fn x -> !x.has_mine && x.status == :closed end)
  end

  @doc """
  Checks if cell contains mine

  ## Example
      iex> Mines.is_mine?([%FieldCell{coordinate: %Coordinate{x: 1, y: 1}}, %FieldCell{coordinate: %Coordinate{x: 1, y: 2}, has_mine: true}], %Coordinate{x: 1, y: 2})
      true
  """
  def is_mine?(game_field, coord) do
    Enum.find(game_field, fn cell ->
      cell.coordinate.x == coord.x && cell.coordinate.y == coord.y && cell.has_mine
    end)
    |> case do
      nil -> false
      _ -> true
    end
  end

  @doc """
  Validate if coordination belong to the field

  ## Examples
      iex> Agent.start_link(fn -> %GameSettings{board_size: 2} end, name: :game_settings)
      iex> Mines.validate_coord(%Coordinate{x: 1, y: 1})
      {:ok, %Coordinate{x: 1, y: 1}}
      iex> Mines.validate_coord(%Coordinate{x: 10, y: 1})
      {:err, "Invalid input."}
  """
  def validate_coord(coordinate) do
    game_settings = Agent.get(:game_settings, & &1)
    validate_coord(coordinate, game_settings)
  end

  defp validate_coord(coordinate, game_settings)
       when coordinate.x in 1..game_settings.board_size and
              coordinate.y in 1..game_settings.board_size do
    {:ok, coordinate}
  end

  defp validate_coord(_, _), do: {:err, "Invalid input."}
end
