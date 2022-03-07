defmodule CrispTest do
  use ExUnit.Case
  doctest Crisp

  test "greets the world" do
    assert Crisp.hello() == :world
  end
end
