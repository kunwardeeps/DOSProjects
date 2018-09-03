defmodule DosProjectTest do
  use ExUnit.Case
  doctest DosProject

  test "greets the world" do
    assert DosProject.hello() == :world
  end
end
