defmodule IslandsEngine.GameTest do
  use ExUnit.Case, async: true
  alias IslandsEngine.Game

  test "start_link/1" do
    assert {:ok, game} = Game.start_link("Frank")
    state_data = :sys.get_state(game)
    assert "Frank" = state_data.player1.name
  end

  test "add_player/2" do
    {:ok, game} = Game.start_link("Frank")

    assert :ok = Game.add_player(game, "Dweezil")
    state_data = :sys.get_state(game)
    assert "Dweezil" = state_data.player2.name
    assert :players_set = state_data.rules.state
  end

  test "position_island/5" do
    {:ok, game} = Game.start_link("Fred")
    Game.add_player(game, "Wilma")

    assert :ok = Game.position_island(game, :player1, :square, 1, 1)
    state_data = :sys.get_state(game)
    assert %{square: _square} = state_data.player1.board

    assert {:error, :invalid_coordinate} = Game.position_island(game, :player1, :dot, 12, 1)
    assert {:error, :invalid_island_type} = Game.position_island(game, :player1, :wrong, 1, 1)
    assert {:error, :invalid_coordinate} = Game.position_island(game, :player1, :l_shape, 10, 10)

    state_data =
      :sys.replace_state(game, fn state_data ->
        %{state_data | rules: %IslandsEngine.Rules{state: :player1_turn}}
      end)

    :player1_turn = state_data.rules.state
    assert :error = Game.position_island(game, :player1, :dot, 5, 5)
  end

  test "set_islands/2" do
    {:ok, game} = Game.start_link("Dino")
    Game.add_player(game, "Pebbles")

    assert {:error, :not_all_islands_positioned} = Game.set_islands(game, :player1)

    :ok = Game.position_island(game, :player1, :atoll, 1, 1)
    :ok = Game.position_island(game, :player1, :dot, 1, 4)
    :ok = Game.position_island(game, :player1, :l_shape, 1, 5)
    :ok = Game.position_island(game, :player1, :s_shape, 5, 1)
    :ok = Game.position_island(game, :player1, :square, 5, 5)
    assert {:ok, _board} = Game.set_islands(game, :player1)

    state_data = :sys.get_state(game)
    assert :islands_set = state_data.rules.player1
    assert :players_set = state_data.rules.state
  end

  test "guess_coordinate/4" do
    {:ok, game} = Game.start_link("Miles")
    assert :error = Game.guess_coordinate(game, :player1, 1, 1)

    Game.add_player(game, "Trane")
    Game.position_island(game, :player1, :dot, 1, 1)
    Game.position_island(game, :player2, :square, 1, 1)

    state_data =
      :sys.replace_state(game, fn data ->
        %{data | rules: %IslandsEngine.Rules{state: :player1_turn}}
      end)

    :player1_turn = state_data.rules.state

    assert {:miss, :none, :no_win} = Game.guess_coordinate(game, :player1, 5, 5)
    assert :error = Game.guess_coordinate(game, :player1, 3, 1)
    assert {:hit, :dot, :win} = Game.guess_coordinate(game, :player2, 1, 1)
  end

  test "via_tuple/1" do
    via = Game.via_tuple("Lena")
    {:ok, pid} = GenServer.start_link(Game, "Lena", name: via)

    state_data = :sys.get_state(via)
    assert "Lena" = state_data.player1.name
    assert {:error, {:already_started, ^pid}} = GenServer.start_link(Game, "Lena", name: via)
  end
end
