defmodule FieldCell do
  @moduledoc """
  Cell of Mines field
  """
  @enforce_keys [:coordinate]
  defstruct [:coordinate, status: :closed, mines_around: 0, has_mine: false]
end

defmodule Coordinate do
  @moduledoc """
  Coordinate struct
  """
  @enforce_keys [:x, :y]
  defstruct [:x, :y]
end
