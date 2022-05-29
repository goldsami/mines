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

  defp fill_game_field(ignore_coord) do
    game_field = get_game_field()
    cells_to_fill = get_random_cells(game_field, get_game_settings().mines_quantity, ignore_coord)

    fill_cells_with_bombs(game_field, cells_to_fill)
    |> fill_cells_with_mines_around_count()
    |> update_game_field()
  end

  defp get_random_cells(game_field, take_quantity, ignore_coord) do
    game_field
    |> Enum.filter(fn cell ->
      cell.coordinate.x != ignore_coord.x && cell.coordinate.y != ignore_coord.y
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
    Agent.get(:game_field, & &1)
  end

  defp update_game_field(game_field) do
    Agent.update(:game_field, fn _ -> game_field end)
  end

  defp get_game_settings() do
    Agent.get(:game_settings, & &1)
  end
end
