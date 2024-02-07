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

  def posts, do: Enum.reverse(@posts)

  def index(assigns) do
    app(%{body: index_file(assigns), title: assigns[:title]})
  end

  def post(post, assigns) do
    post_md = apply(KsWeb.Templates, post.template, [assigns])
    post_text = Earmark.as_html!(post_md)
    post_assigns = Map.merge(assigns, %{post: post, post_text: post_text})

    post_body = KsWeb.Templates.post_file(post_assigns)
    app(Map.merge(assigns, %{body: post_body}))
  end
end
