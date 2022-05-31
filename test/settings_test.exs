defmodule GameSettingsTest do
  use ExUnit.Case
  doctest GameSettings

  test "Writes settings to store" do
    {:ok, pid} =
      GameSettings.write_settings_to_store(%GameSettings{board_size: 2, mines_quantity: 1})

    assert Agent.get(pid, & &1) == %GameSettings{board_size: 2, mines_quantity: 1}
  end

  test "Returns settings from store" do
    GameSettings.write_settings_to_store(%GameSettings{board_size: 2, mines_quantity: 1})
    assert GameSettings.get_game_settings() == %GameSettings{board_size: 2, mines_quantity: 1}
  end

  test "Clears settings from store" do
    Agent.start_link(fn -> %GameSettings{} end, name: :game_settings)
    GameSettings.crear_game_settings()

    assert Process.whereis(:game_settings) == nil
  end
end
