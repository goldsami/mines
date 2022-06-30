defmodule GameField do
  @moduledoc """
  Module for interaction with game field
  """

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
    game_field = Agent.get(:game_field, & &1)

    cells_to_fill =
      get_random_cells(
        game_field,
        Agent.get(:game_settings, & &1).mines_quantity,
        ignore_coord
      )

    new_field =
      fill_cells_with_bombs(game_field, cells_to_fill)
      |> fill_cells_with_mines_around_count()

    Agent.update(:game_field, fn _ -> new_field end)

    new_field
  end

  # TODO: add test for 1-arity
  @doc """
  Sets cell status to open

  ## Example
      iex> Agent.start_link(fn -> %GameSettings{board_size: 2, mines_quantity: 1} end, name: :game_settings)
      iex> Agent.start_link(fn -> [] end, name: :game_field)
      iex> GameField.open_cell([%FieldCell{status: :closed, has_mine: true, coordinate: %Coordinate{x: 1, y: 1}}, %FieldCell{status: :closed, mines_around: 1, coordinate: %Coordinate{x: 1, y: 2}}], %Coordinate{x: 1, y: 2})
      [%FieldCell{status: :closed, has_mine: true, coordinate: %Coordinate{x: 1, y: 1}}, %FieldCell{status: :open, mines_around: 1, coordinate: %Coordinate{x: 1, y: 2}}]
  """
  def open_cell(cell_coord) do
    Agent.get(:game_field, & &1) |> open_cell(cell_coord)
  end

  def open_cell(game_field, cell_coord) do
    Mines.find_cell_by_coord(game_field, cell_coord)
    |> case do
      %FieldCell{status: :open} ->
        game_field

      %FieldCell{mines_around: 0} ->
        set_cell_status(game_field, cell_coord, :open)
        |> get_neighbour_cells(cell_coord)
        |> Enum.each(fn cell -> open_cell(cell.coordinate) end)

        Agent.get(:game_field, & &1)

      _ ->
        set_cell_status(game_field, cell_coord, :open)
    end
  end

  # TODO: test case when flag an open cell
  @doc """
  Sets cell status to flag

  ## Example
      iex> Agent.start_link(fn -> %GameSettings{board_size: 2, mines_quantity: 1} end, name: :game_settings)
      iex> Agent.start_link(fn -> [] end, name: :game_field)
      iex> GameField.flag_cell([%FieldCell{status: :closed, coordinate: %Coordinate{x: 1, y: 1}}, %FieldCell{status: :closed, coordinate: %Coordinate{x: 1, y: 2}}], %Coordinate{x: 1, y: 2})
      [%FieldCell{status: :closed, coordinate: %Coordinate{x: 1, y: 1}}, %FieldCell{status: :flag, coordinate: %Coordinate{x: 1, y: 2}}]
  """
  def flag_cell(game_field, cell_coord) do
    case Mines.find_cell_by_coord(game_field, cell_coord) do
      %FieldCell{status: :open} -> game_field
      _ -> set_cell_status(game_field, cell_coord, :flag)
    end
  end

  defp set_cell_status(game_field, cell_coord, new_status) do
    case Mines.validate_coord(cell_coord) do
      {:ok, _} ->
        new_field =
          Enum.map(game_field, fn cell ->
            cond do
              cell.coordinate.x == cell_coord.x && cell.coordinate.y == cell_coord.y ->
                %FieldCell{cell | status: new_status}

              true ->
                cell
            end
          end)

        Agent.update(:game_field, fn _ -> new_field end)

        new_field

      err ->
        err
    end
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
end
