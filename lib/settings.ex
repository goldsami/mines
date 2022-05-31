defmodule GameSettings do
  @moduledoc """
  Game settings like board size and mines count.
  """
  defstruct board_size: 3, mines_quantity: 3

  @settings_store_name :game_settings

  @doc """
  Writes settings to store

  ## Examples
      iex> {:ok, pid} = GameSettings.write_settings_to_store(%GameSettings{board_size: 2, mines_quantity: 1})
      iex> Agent.get(pid, & &1)
      %GameSettings{board_size: 2, mines_quantity: 1}
  """
  def write_settings_to_store(game_settings) do
    Agent.start_link(fn -> game_settings end, name: @settings_store_name)
  end

  @doc """
  Gets settings from store

  ## Examples
      iex> GameSettings.write_settings_to_store(%GameSettings{board_size: 2, mines_quantity: 1})
      iex> GameSettings.get_game_settings()
      %GameSettings{board_size: 2, mines_quantity: 1}
  """
  def get_game_settings() do
    Agent.get(@settings_store_name, & &1)
  end

  @doc """
  Clears game settings

  ## Examples
      iex> Agent.start_link(fn -> %GameSettings{} end, name: :game_settings)
      iex> GameSettings.crear_game_settings()
      :ok
      iex> Process.whereis(:game_settings)
      nil
  """
  def crear_game_settings() do
    Agent.stop(@settings_store_name)
  end
end
