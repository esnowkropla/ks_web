defmodule KsWeb.Tags do
  alias KsWeb.Tags.Tag

  def make_tags(posts) do
    posts
    |> tags_with_counts
    |> Enum.map(fn {tag, count} ->
      %Tag{text: tag, count: count, slug: KsWeb.Sluggify.slug!(tag)}
    end)
  end

  def get_tags(posts) do
    posts
    |> Enum.flat_map(& &1.tags)
    |> Enum.sort()
    |> Enum.uniq()
  end

  def tags_with_counts(posts) do
    posts
    |> Enum.flat_map(& &1.tags)
    |> Enum.frequencies()
    |> Enum.to_list()
    |> Enum.sort_by(fn {_, count} -> count end, :desc)
  end
end
