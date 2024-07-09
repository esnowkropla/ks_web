defmodule KsWeb.Feed do
  alias KsWeb.Posts.Post
  import KsWeb.Templates, only: [post_body: 3]
  alias Atomex.{Feed, Entry}

  # Host must =~ ~r{/\z}
  def build_feed(posts, assigns) do
    host = assigns.host

    Feed.new(host, DateTime.utc_now(), "Elliot Snow-Kropla")
    |> Feed.author("Elliot Snow-Kropla", email: "elliot@kropla.ca")
    |> Feed.link("#{host}feed.atom", rel: :self)
    |> Feed.entries(Enum.map(posts, &get_entry(&1, posts, assigns)))
    |> Feed.build()
    |> Atomex.generate_document()
  end

  def get_entry(post = %Post{}, posts, assigns) do
    host = assigns.host

    Entry.new("#{host}#{String.trim_leading(post.url, "/")}", date(post), post.title)
    |> Entry.content(post_body(post, posts, assigns), type: "html")
    |> Entry.link(post.url, rel: :alternate)
    |> Entry.build()
  end

  defp date(%Post{published_at: nil, created_at: created_at}), do: created_at
  defp date(%Post{published_at: published_at}), do: published_at
end
