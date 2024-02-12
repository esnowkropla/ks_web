defmodule KsWeb.Templates do
  require EEx

  alias KsWeb.Posts

  paths = Path.wildcard("templates/*.md.eex")
  paths_hash = :erlang.md5(paths)

  for path <- paths do
    @external_resource path
  end

  def __mix_recompile__?() do
    Path.wildcard("templates/*.eex") |> :erlang.md5() != unquote(paths_hash)
  end

  Module.register_attribute(__MODULE__, :posts, accumulate: true)

  File.ls!("templates/posts")
  |> Enum.each(fn file ->
    post = Posts.process_post(file)
    @posts post

    EEx.function_from_string(:def, post.template, post.content, [:assigns])
  end)

  EEx.function_from_file(:def, :app, "templates/app.html.eex", [:assigns])
  EEx.function_from_file(:def, :index_file, "templates/index.html.eex", [:assigns])
  EEx.function_from_file(:def, :post_file, "templates/post.html.eex", [:assigns])
  EEx.function_from_file(:def, :projects_file, "templates/projects.html.eex", [:assigns])
  EEx.function_from_file(:def, :blog_file, "templates/blog.html.eex", [:assigns])

  def posts, do: Enum.reverse(@posts)

  def published_posts do
    posts()
    |> Enum.filter(&(&1.published_at != nil))
    |> Enum.sort({:desc, Posts})
    |> Enum.with_index()
    |> Enum.map(fn {post, index} ->
      %{post | index: index}
    end)
  end

  def index(assigns) do
    app(Map.merge(assigns, %{body: index_file(assigns), title: assigns[:title]}))
  end

  def post_body(post, assigns) do
    post_md = apply(KsWeb.Templates, post.template, [assigns])
    post_text = Earmark.as_html!(post_md)
    previous_post = Posts.previous_post(post)
    next_post = Posts.next_post(post)

    post_assigns =
      assigns
      |> Map.merge(%{
        post: post,
        post_text: post_text,
        next_post: next_post,
        previous_post: previous_post
      })

    post_file(post_assigns)
  end

  def post(post, assigns) do
    app(Map.merge(assigns, %{body: post_body(post, assigns)}))
  end

  def projects(assigns) do
    app(Map.merge(assigns, %{body: projects_file(assigns)}))
  end

  def blog(assigns) do
    app(Map.merge(assigns, %{body: blog_file(assigns)}))
  end
end
