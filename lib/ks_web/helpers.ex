defmodule KsWeb.Helpers do
  alias KsWeb.Posts.Post
  alias KsWeb.Sidenote

  def img(id, path, do: text) do
    ~s"""
    <figure>
      #{margin_note(id, do: text)}
      <img class="photo" src="#{path}" />
    </figure>
    """
  end

  def side_note(id, do: text) do
    template = ~s"""
    <label class="margin-toggle sidenote-number" for="#{id}"></label>
    <input id="#{id}" class="margin-toggle" type="checkbox"/>
    <span class="sidenote">
    #{text}
    </span>
    """

    Sidenote.store(id, String.trim(template))

    Sidenote.pattern(id)
  end

  def margin_note(id, do: text) do
    template = ~s"""
    <label class="margin-toggle" for="#{id}">⊕</label>
    <input id="#{id}" class="margin-toggle" type="checkbox"/>
    <span class="marginnote">
    #{text}
    </span>
    """

    Sidenote.store(id, String.trim(template))

    Sidenote.pattern(id)
  end

  def group_posts_by_year(posts) do
    Enum.group_by(posts, & &1.published_at.year)
    |> Enum.to_list()
    |> Enum.sort_by(fn {year, _} -> year end, :desc)
  end

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
