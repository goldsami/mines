defmodule ConsoleGest do
  use ExUnit.Case
  doctest Test

  test "console test" do
    assert Test.test() == "ggwp"
  end
end
