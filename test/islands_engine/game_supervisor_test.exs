defmodule IslandsEngine.GameSupervisorTest do
  use ExUnit.Case, async: true
  alias IslandsEngine.{Game, GameSupervisor}

  test "starting and stopping a game process" do
    assert {:ok, game} = GameSupervisor.start_game("Cassatt")
    via = Game.via_tuple("Cassatt")
    assert ^game = GenServer.whereis(via)
    assert [{:undefined, ^game, :worker, [IslandsEngine.Game]}] =
             Supervisor.which_children(GameSupervisor)

    assert :ok = GameSupervisor.stop_game("Cassatt")
    assert false == Process.alive?(game)
    assert nil == GenServer.whereis(via)
  end
end
