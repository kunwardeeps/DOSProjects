defmodule DosProjectTest do
  use ExUnit.Case
  doctest DosProject

  test "greets the world" do
    assert DosProject.loop(1000, 1000, 1000, 409)
  end
end
