defmodule IslandsEngine.Guesses do
  alias IslandsEngine.{Coordinate, Guesses}

  @enforce_keys [:hits, :misses]
  defstruct [:hits, :misses]

  @doc """
  Creates a new Guesses struct.
  """
  def new, do: %Guesses{hits: MapSet.new(), misses: MapSet.new()}

  @doc """
  Adds a guessed coordinate to a Guesses struct.

  ## Examples

      iex> alias IslandsEngine.{Coordinate, Guesses}
      iex> guesses = Guesses.new()
      iex> {:ok, coordinate1} = Coordinate.new(8, 3)
      iex> guesses = Guesses.add(guesses, :hit, coordinate1)
      iex> {:ok, coordinate2} = Coordinate.new(9, 7)
      iex> guesses = Guesses.add(guesses, :hit, coordinate2)
      iex> {:ok, coordinate3} = Coordinate.new(1, 2)
      iex> guesses = Guesses.add(guesses, :miss, coordinate3)
      iex> guesses.hits
      #MapSet<[%IslandsEngine.Coordinate{col: 3, row: 8}, %IslandsEngine.Coordinate{col: 7, row: 9}]>
      iex> guesses.misses
      #MapSet<[%IslandsEngine.Coordinate{col: 2, row: 1}]>
  """
  def add(%Guesses{} = guesses, :hit, %Coordinate{} = coordinate),
    do: update_in(guesses.hits, &MapSet.put(&1, coordinate))

  def add(%Guesses{} = guesses, :miss, %Coordinate{} = coordinate),
    do: update_in(guesses.misses, &MapSet.put(&1, coordinate))
end
