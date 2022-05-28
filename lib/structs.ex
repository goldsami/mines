defmodule FieldCell do
  @moduledoc """
  Cell of Mines field
  """
  @enforce_keys [:coordinate]
  defstruct [:coordinate, has_mine: false, is_opened: false]
end

defmodule Coordinate do
  @moduledoc """
  Coordinate struct
  """
  @enforce_keys [:x, :y]
  defstruct [:x, :y]
end

defmodule GameSettings do
  @moduledoc """
  Game settings like board size and mines count.
  """
  defstruct board_size: 8, mines_quantity: 10
end
