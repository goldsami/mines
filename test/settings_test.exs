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
end
