defmodule IslandsEngine.GameSupervisorTest do
  use ExUnit.Case, async: true
  alias IslandsEngine.{Game, GameSupervisor}

  test "starting and stopping a game process" do
    assert {:ok, game} = GameSupervisor.start_game("Cassatt")
    via = Game.via_tuple("Cassatt")
    assert ^game = GenServer.whereis(via)
    assert [{_name, _state}] = :ets.lookup(:game_state, "Cassatt")

    assert :ok = GameSupervisor.stop_game("Cassatt")

    assert false == Process.alive?(game)
    assert nil == GenServer.whereis(via)
    assert [] = :ets.lookup(:game_state, "Cassatt")
  end

  test "recovering state after a crash" do
    {:ok, game} = GameSupervisor.start_game("Morandi")
    via = Game.via_tuple("Morandi")

    [{"Morandi", value}] = :ets.lookup(:game_state, "Morandi")
    assert "Morandi" = value.player1.name
    assert nil == value.player2.name

    Game.add_player(game, "Rothko")

    [{"Morandi", value}] = :ets.lookup(:game_state, "Morandi")
    assert "Morandi" = value.player1.name
    assert "Rothko" = value.player2.name

    Process.exit(game, :kaboom)

    state_data = :sys.get_state(via)
    assert "Morandi" = state_data.player1.name
    assert "Rothko" = state_data.player2.name
  end
end
