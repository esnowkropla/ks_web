defmodule KsWeb.Helpers do
  alias KsWeb.Posts.Post

  def date(%Post{published_at: published_at}) do
    "#{published_at.year}-#{month(published_at)}-#{day(published_at)}"
  end

  defmacro sigil_E(expr, opts) do
    handle_sigil(expr, opts, __CALLER__.line)
  end

  # Private

  defp handle_sigil({:<<>>, _, [expr]}, [], line) do
    EEx.compile_string(expr, engine: EEx.Engine, line: line + 1)
  end

  defp month(date) do
    date.month
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end

  defp day(date) do
    date.day
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end
end
