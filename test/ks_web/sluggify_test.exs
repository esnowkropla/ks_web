defmodule KsWeb.SluggifyTest do
  use ExUnit.Case

  import KsWeb.Sluggify, only: [slug: 1]

  test "it errors if it would output an empty string" do
    assert {:err, _} = slug("")
    assert {:err, _} = slug("`")
  end

  test "it lowercases letters" do
    assert slug("hElLo") == {:ok, "hello"}
  end

  test "it replaces whitespace" do
    assert slug("Hello world") == {:ok, "hello-world"}
  end

  test "it strips out punctuation" do
    assert slug("Hello, world!") == {:ok, "hello-world"}
  end
end
