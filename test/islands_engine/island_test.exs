defmodule IslandsEngine.IslandTest do
  use ExUnit.Case, async: true
  doctest IslandsEngine.Island

  alias IslandsEngine.{Coordinate, Island}

  test "guessing coordinate" do
    {:ok, dot_coordinate} = Coordinate.new(4, 4)
    {:ok, dot} = Island.new(:dot, dot_coordinate)

    {:ok, coordinate} = Coordinate.new(2, 2)
    assert :miss = Island.guess(dot, coordinate)

    {:ok, new_coordinate} = Coordinate.new(4, 4)
    assert {:hit, dot} = Island.guess(dot, new_coordinate)
    assert Island.forested?(dot)
  end
end
