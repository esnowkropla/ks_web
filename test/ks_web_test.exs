defmodule KsWebTest do
  use ExUnit.Case
  doctest KsWeb

  test "greets the world" do
    assert KsWeb.hello() == :world
  end
end
