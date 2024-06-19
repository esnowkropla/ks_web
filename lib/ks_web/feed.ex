defmodule KsWeb.Feed do
  alias KsWeb.Posts.Post
  alias Atomex.{Feed, Entry}

  # Host must =~ ~r{/\z}
  def build_feed(posts, host) do
    Feed.new(host, DateTime.utc_now(), "Elliot Snow-Kropla's Feed")
    |> Feed.author("Elliot Snow-Kropla", email: "elliot@kropla.ca")
    |> Feed.link("#{host}feed.atom", rel: :self)
    |> Feed.entries(Enum.map(posts, &get_entry(&1, host)))
    |> Feed.build()
    |> Atomex.generate_document()
  end

  def get_entry(post = %Post{}, host) do
    Entry.new("#{host}#{String.trim_leading(post.url, "/")}", post.published_at, post.title)
    |> Entry.author("Elliot Snow-Kropla", uri: host)
    |> Entry.content(post.content, type: "html")
    |> Entry.link(post.url, rel: :alternate)
    |> Entry.build()
  end
end
