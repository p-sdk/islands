defmodule IslandsEngine.RulesTest do
  use ExUnit.Case, async: true
  alias IslandsEngine.Rules

  test ":initialized state" do
    rules = Rules.new()
    assert :initialized = rules.state

    assert :error = Rules.check(rules, :completely_wrong_action)

    assert {:ok, rules} = Rules.check(rules, :add_player)
    assert :players_set = rules.state
  end

  test ":players_set state" do
    rules = Rules.new()
    rules = %{rules | state: :players_set}
    :players_set = rules.state

    assert {:ok, rules} = Rules.check(rules, {:position_islands, :player1})
    assert {:ok, rules} = Rules.check(rules, {:position_islands, :player2})
    assert :players_set = rules.state

    assert {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
    assert {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
    assert :players_set = rules.state

    assert :error = Rules.check(rules, {:position_islands, :player1})
    assert {:ok, rules} = Rules.check(rules, {:position_islands, :player2})

    assert {:ok, rules} = Rules.check(rules, {:set_islands, :player2})
    assert :error = Rules.check(rules, {:position_islands, :player2})

    assert :player1_turn = rules.state
    assert :error = Rules.check(rules, {:set_islands, :player2})

    assert :error = Rules.check(rules, :add_player)
    assert :error = Rules.check(rules, {:position_islands, :player1})
    assert :error = Rules.check(rules, {:position_islands, :player2})
    assert :error = Rules.check(rules, {:set_islands, :player1})
  end

  test "player turn states" do
    rules = Rules.new()
    rules = %{rules | state: :player1_turn}
    {:ok, rules: rules}

    assert :error = Rules.check(rules, {:guess_coordinate, :player2})
    assert {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player1})
    assert :player2_turn = rules.state

    assert :error = Rules.check(rules, {:guess_coordinate, :player1})
    assert {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player2})
    assert :player1_turn = rules.state

    assert {:ok, rules} = Rules.check(rules, {:win_check, :no_win})
    assert :player1_turn = rules.state

    assert {:ok, rules} = Rules.check(rules, {:win_check, :win})
    assert :game_over = rules.state
  end
end
