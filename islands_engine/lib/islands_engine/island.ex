defmodule IslandsEngine.Island do
  alias IslandsEngine.{Coordinate, Island}

  @enforce_keys [:coordinates, :hit_coordinates]
  defstruct [:coordinates, :hit_coordinates]

  @doc """
  Creates a new Island for the given island `type` and `upper_left` coordinate.

  ## Examples

      iex> alias IslandsEngine.{Coordinate, Island}
      iex> {:ok, coordinate} = Coordinate.new(4, 6)
      iex> {:ok, %Island{}} = Island.new(:l_shape, coordinate)
      iex> Island.new(:wrong, coordinate)
      {:error, :invalid_island_type}
      iex> {:ok, coordinate} = Coordinate.new(10, 10)
      iex> Island.new(:l_shape, coordinate)
      {:error, :invalid_coordinate}
  """
  def new(type, %Coordinate{} = upper_left) do
    with [_ | _] = offsets <- offsets(type),
         %MapSet{} = coordinates <- add_coordinates(offsets, upper_left) do
      {:ok, %Island{coordinates: coordinates, hit_coordinates: MapSet.new()}}
    else
      error -> error
    end
  end

  defp offsets(:square), do: [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
  defp offsets(:atoll), do: [{0, 0}, {0, 1}, {1, 1}, {2, 0}, {2, 1}]
  defp offsets(:dot), do: [{0, 0}]
  defp offsets(:l_shape), do: [{0, 0}, {1, 0}, {2, 0}, {2, 1}]
  defp offsets(:s_shape), do: [{0, 1}, {0, 2}, {1, 0}, {1, 1}]
  defp offsets(_), do: {:error, :invalid_island_type}

  defp add_coordinates(offsets, upper_left) do
    Enum.reduce_while(offsets, MapSet.new(), fn offset, acc ->
      add_coordinate(acc, upper_left, offset)
    end)
  end

  defp add_coordinate(coordinates, %Coordinate{row: row, col: col}, {row_offset, col_offset}) do
    case Coordinate.new(row + row_offset, col + col_offset) do
      {:ok, coordinate} ->
        {:cont, MapSet.put(coordinates, coordinate)}

      {:error, :invalid_coordinate} ->
        {:halt, {:error, :invalid_coordinate}}
    end
  end

  @doc """
  Checks if the given islands have any common coordinates.

  ## Examples

      iex> alias IslandsEngine.{Coordinate, Island}
      iex> {:ok, square_coordinate} = Coordinate.new(1, 1)
      iex> {:ok, square} = Island.new(:square, square_coordinate)
      iex> {:ok, dot_coordinate} = Coordinate.new(1, 2)
      iex> {:ok, dot} = Island.new(:dot, dot_coordinate)
      iex> {:ok, l_shape_coordinate} = Coordinate.new(5, 5)
      iex> {:ok, l_shape} = Island.new(:l_shape, l_shape_coordinate)
      iex> Island.overlaps?(square, dot)
      true
      iex> Island.overlaps?(square, l_shape)
      false
      iex> Island.overlaps?(dot, l_shape)
      false
  """
  def overlaps?(existing_island, new_island),
    do: not MapSet.disjoint?(existing_island.coordinates, new_island.coordinates)

  def guess(island, coordinate) do
    case MapSet.member?(island.coordinates, coordinate) do
      true ->
        hit_coordinates = MapSet.put(island.hit_coordinates, coordinate)
        {:hit, %{island | hit_coordinates: hit_coordinates}}

      false ->
        :miss
    end
  end

  def forested?(island),
    do: MapSet.equal?(island.coordinates, island.hit_coordinates)

  def types, do: [:atoll, :dot, :l_shape, :s_shape, :square]
end
