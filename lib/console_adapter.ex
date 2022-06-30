defmodule MinesConsoleGame do
  @moduledoc """
  Console adapter for Mines game.
  """

  def start_game() do
    game_settings = %GameSettings{mines_quantity: 2}

    Mines.init_game(game_settings)
    |> print_game_field(game_settings)

    request_valid_x_y()
    |> Mines.start_game()
    |> print_game_field(game_settings)
    |> do_step(game_settings)
  end

  defp do_step(game_field, game_settings) do
    with {:ok, command, coord} <- request_action(),
         # TODO seems that loose is goes in execute command
         {:ok, new_game_field} <- execute_command(game_field, {command, coord}) do
      print_game_field(new_game_field, game_settings)
      do_step(new_game_field, game_settings)
    else
      :win ->
        "You win!"

      :defeat ->
        "You lost"

      {:err, msg} ->
        IO.write("#{msg}\n")
        do_step(game_field, game_settings)
    end
  end

  defp request_action() do
    IO.gets(
      "Enter action in next format: 'l/r X_COORD Y_COORD', where 'l' and 'r' are left/right click\n"
    )
    |> String.trim()
    |> parse_action()
  end

  defp execute_command(game_field, {command, coord}) do
    cond do
      command == "l" ->
        Mines.left_click(game_field, coord)

      command == "r" ->
        Mines.right_click(game_field, coord)
    end
  end

  defp parse_action(action) do
    with {:ok, splitted_action} <- split_action(action),
         {:ok, command} <- get_command_from_splitted_action(splitted_action),
         {:ok, coord} <- get_x_y_from_splitted_action(splitted_action) do
      {:ok, command, coord}
    else
      err -> err
    end
  end

  defp split_action(action) do
    splitted_action = String.split(action, " ")

    case Enum.count(splitted_action) == 3 do
      true -> {:ok, splitted_action}
      false -> {:err, "Invalid input format."}
    end
  end

  defp get_command_from_splitted_action([command | _]) do
    case command == "l" || command == "r" do
      true -> {:ok, command}
      false -> {:err, "Invalid click command"}
    end
  end

  defp get_x_y_from_splitted_action([_, str_x, str_y]) do
    with {x, _} <- Integer.parse(str_x),
         {y, _} <- Integer.parse(str_y),
         {:ok, coord} <- Mines.validate_coord(%Coordinate{x: x, y: y}) do
      {:ok, coord}
    else
      err -> err
    end
  end

  defp request_valid_x_y() do
    request_x_y()
    |> Mines.validate_coord()
    |> case do
      {:ok, coord} ->
        coord

      {:err, msg} ->
        IO.write("\n#{msg}\n")
        request_valid_x_y()
    end
  end

  defp request_x_y() do
    {x, _} = IO.gets("Enter x: ") |> Integer.parse()
    {y, _} = IO.gets("Enter y: ") |> Integer.parse()

    %Coordinate{x: x, y: y}
  end

  defp print_game_field(game_field, game_settings) do
    IO.write("  ")
    for n <- 1..game_settings.board_size, do: IO.write(" #{n}")

    for y <- 1..game_settings.board_size do
      IO.write("\n#{y} ")

      for(
        x <- 1..game_settings.board_size,
        do: Mines.find_cell_by_coord(game_field, %Coordinate{x: x, y: y}) |> write_cell_to_console
      )
    end

    IO.write("\n")

    game_field
  end

  defp write_cell_to_console(cell) do
    cond do
      cell.status == :closed -> " #"
      cell.status == :flag && cell.status != :open -> " F"
      cell.has_mine -> " *"
      true -> " #{cell.mines_around}"
    end
    |> IO.write()
  end
end
