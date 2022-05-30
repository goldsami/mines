defmodule GameField do
  @moduledoc """
  Module for interaction with game field
  """

  @game_field_store_name :game_field

  @doc """
  Generates empty game field

  ## Examples
      iex> GameField.generate_game_field(%GameSettings{board_size: 2, mines_quantity: 1})
      [
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
  """
  def generate_game_field(game_settings) do
    cells =
      for x <- 1..game_settings.board_size,
          do:
            for(
              y <- 1..game_settings.board_size,
              do: %FieldCell{coordinate: %Coordinate{x: x, y: y}}
            )

    List.flatten(cells)
  end

  @doc """
  Writes input field to store

  ## Example
      iex> {:ok, pid} = GameField.write_game_field_to_store([%FieldCell{coordinate: %Coordinate{x: 1, y: 1}}])
      iex> Agent.get(pid, fn state -> state end)
      [%FieldCell{coordinate: %Coordinate{x: 1, y: 1}}]
  """
  def write_game_field_to_store(game_field) do
    Agent.start_link(fn -> game_field end, name: @game_field_store_name)
  end

  @doc """
  Randomly fills game field with bombs and numbers

  ## Example
      iex> Agent.start_link(fn -> %GameSettings{board_size: 2, mines_quantity: 1} end, name: :game_settings)
      iex> Agent.start_link(fn -> [%FieldCell{coordinate: %Coordinate{x: 1, y: 1}}, %FieldCell{coordinate: %Coordinate{x: 1, y: 2}}] end, name: :game_field)
      iex> GameField.fill_game_field(%Coordinate{x: 1, y: 1})
      iex> Agent.get(:game_field, & &1)
      [
        %FieldCell{
               coordinate: %Coordinate{x: 1, y: 1},
               mines_around: 1,
               status: :closed,
               has_mine: false
             },
        %FieldCell{
               coordinate: %Coordinate{x: 1, y: 2},
               mines_around: 0,
               status: :closed,
               has_mine: true
             }
      ]

  """
  def fill_game_field(ignore_coord) do
    game_field = get_game_field()

    cells_to_fill =
      get_random_cells(game_field, GameSettings.get_game_settings().mines_quantity, ignore_coord)

    # IO.inspect(cells_to_fill)

    fill_cells_with_bombs(game_field, cells_to_fill)
    |> fill_cells_with_mines_around_count()
    |> update_game_field()
  end

  defp get_random_cells(game_field, take_quantity, ignore_coord) do
    game_field
    |> Enum.filter(fn cell ->
      !(cell.coordinate.x == ignore_coord.x && cell.coordinate.y == ignore_coord.y)
    end)
    |> Enum.shuffle()
    |> Enum.take(take_quantity)
  end

  defp fill_cells_with_bombs(game_field, cells_to_fill) do
    Enum.map(game_field, fn cell ->
      cond do
        Enum.member?(cells_to_fill, cell) -> %FieldCell{cell | has_mine: true}
        true -> cell
      end
    end)
  end

  defp fill_cells_with_mines_around_count(game_field) do
    Enum.map(game_field, fn cell ->
      %FieldCell{cell | mines_around: count_mines_around_cell(game_field, cell.coordinate)}
    end)
  end

  defp count_mines_around_cell(game_field, current_coords) do
    get_neighbour_cells(game_field, current_coords)
    |> count_mines_of_cells()
  end

  defp get_neighbour_cells(game_field, current_coords) do
    Enum.filter(game_field, fn cell ->
      cond do
        cell.coordinate.x == current_coords.x - 1 && cell.coordinate.y == current_coords.y - 1 ->
          true

        cell.coordinate.x == current_coords.x - 1 && cell.coordinate.y == current_coords.y ->
          true

        cell.coordinate.x == current_coords.x - 1 && cell.coordinate.y == current_coords.y + 1 ->
          true

        cell.coordinate.x == current_coords.x && cell.coordinate.y == current_coords.y - 1 ->
          true

        cell.coordinate.x == current_coords.x && cell.coordinate.y == current_coords.y + 1 ->
          true

        cell.coordinate.x == current_coords.x + 1 && cell.coordinate.y == current_coords.y - 1 ->
          true

        cell.coordinate.x == current_coords.x + 1 && cell.coordinate.y == current_coords.y ->
          true

        cell.coordinate.x == current_coords.x + 1 && cell.coordinate.y == current_coords.y + 1 ->
          true

        true ->
          false
      end
    end)
  end

  defp count_mines_of_cells(cells) do
    Enum.filter(cells, fn cell -> cell.has_mine end)
    |> Enum.count()
  end

  defp get_game_field() do
    Agent.get(@game_field_store_name, & &1)
  end

  defp update_game_field(game_field) do
    Agent.update(@game_field_store_name, fn _ -> game_field end)
  end
end
