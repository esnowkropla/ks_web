defmodule KsWeb.SidenoteTest do
  use ExUnit.Case

  import KsWeb.Sidenote

  setup [:text]

  describe "get_marks/1" do
    test "it finds the sidenote insert marks", %{text: text} do
      assert get_marks(text) == ["1", "2"]
    end
  end

  describe "replace_all_marks/1" do
    setup [:store_marks]

    test "it replaces all marks", %{text: text} do
      assert replace_all_marks(text) ==
               "words words foobar some more words some more words quux words"
    end
  end

  defp text(_) do
    %{text: "words words ^^SIDENOTE{1}^^ some more words some more words ^^SIDENOTE{2}^^ words"}
  end

  defp store_marks(_) do
    store("1", "foobar")
    store("2", "quux")

    %{}
  end
end
