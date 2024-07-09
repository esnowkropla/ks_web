defmodule KsWeb.Posts do
  alias KsWeb.Posts.Post
  alias KsWeb.Tags.Tag

  defdelegate posts, to: KsWeb.Templates

  def published_posts do
    posts()
    |> Enum.filter(&(&1.published_at != nil))
    |> Enum.sort({:desc, __MODULE__})
    |> Enum.with_index()
    |> Enum.map(fn {post, index} ->
      %{post | index: index}
    end)
  end

  def all_posts do
    posts()
    |> Enum.sort({:desc, __MODULE__})
    |> Enum.with_index()
    |> Enum.map(fn {post, index} ->
      %{post | index: index}
    end)
  end

  @tag_list_pattern ~r/^tags[[:space:]]*=[[:space:]]*(.+)$/m
  @published_at_pattern ~r/^published_at[[:space:]]*=[[:space:]]*"(.+)"$/m
  @created_at_pattern ~r/^created_at[[:space:]]*=[[:space:]]*"(.+)"$/m
  @title_pattern ~r/^title[[:space:]]*=[[:space:]]*"(.+)"$/m

  def next_post(_posts, %Post{index: 0}), do: nil

  def next_post(posts, %Post{index: index}) do
    case Enum.fetch(posts, index - 1) do
      {:ok, post} -> post
      :error -> nil
    end
  end

  def previous_post(posts, %Post{index: index}) do
    case Enum.fetch(posts, index + 1) do
      {:ok, post} -> post
      :error -> nil
    end
  end

  def posts_for_tag(posts, %Tag{text: tag}) do
    Enum.filter(posts, fn post -> Enum.any?(post.tags, &(&1 == tag)) end)
  end

  def process_post(file) do
    [file_name, _] = String.split(file, ".", parts: 2)
    fn_name = :"#{file_name}"
    path = "templates/posts/#{file}"

    body = File.read!(path)
    [meta, content] = process_body(body)

    %Post{
      template: fn_name,
      content: content,
      path: path,
      created_at: meta[:created_at],
      published_at: meta[:published_at],
      title: meta[:title],
      tags: meta[:tags],
      slug: KsWeb.Sluggify.slug!(file_name),
      url: "/posts/#{KsWeb.Sluggify.slug!(file_name)}.html"
    }
  end

  def process_body(body) do
    if String.starts_with?(body, "+++") do
      [_, meta_text, content] = String.split(body, "+++", parts: 3)
      meta = process_meta(meta_text)
      [meta, content]
    else
      [%{}, body]
    end
  end

  def process_meta(meta_text) do
    %{
      tags: get_tags(meta_text),
      published_at: get_published_at(meta_text),
      created_at: get_created_at(meta_text),
      title: get_title(meta_text)
    }
  end

  def get_title(meta_text) do
    case Regex.run(@title_pattern, meta_text, capture: :all_but_first) do
      nil -> nil
      [title] -> title
    end
  end

  def get_tags(meta_text) do
    case Regex.run(@tag_list_pattern, meta_text, capture: :all_but_first) do
      nil -> []
      [tag_list_string] -> get_tags_from_tag_list(tag_list_string)
    end
  end

  def get_tags_from_tag_list(tag_list) do
    Regex.scan(~r/"(.+?)"/, tag_list, capture: :all_but_first)
    |> List.flatten()
  end

  def get_published_at(meta_text) do
    with [date_text] <- Regex.run(@published_at_pattern, meta_text, capture: :all_but_first) do
      {:ok, dt, _} = DateTime.from_iso8601(date_text)

      dt
    end
  end

  def get_created_at(meta_text) do
    with [date_text] <- Regex.run(@created_at_pattern, meta_text, capture: :all_but_first) do
      {:ok, dt, _} = DateTime.from_iso8601(date_text)

      dt
    end
  end

  def compare(%Post{} = post1, %Post{} = post2) do
    if post1.published_at == nil || post2.published_at == nil do
      DateTime.compare(post1.created_at, post2.created_at)
    else
      DateTime.compare(post1.published_at, post2.published_at)
    end
  end
end
