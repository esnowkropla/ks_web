defmodule KsWeb.Templates do
  require EEx

  alias KsWeb.Posts

  import KsWeb.Helpers
  import KsWeb.Sluggify, only: [slug!: 1]

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
  EEx.function_from_file(:def, :projects_file, "templates/projects.html.eex", [])
  EEx.function_from_file(:def, :blog_file, "templates/blog.html.eex", [:assigns])
  EEx.function_from_file(:def, :tag_index_file, "templates/tags/index.html.eex", [:assigns])
  EEx.function_from_file(:def, :tag_file, "templates/tag.html.eex", [:assigns])

  def posts, do: Enum.reverse(@posts)

  def index(posts, assigns) do
    app(
      Map.merge(assigns, %{
        body:
          index_file(Map.put(assigns, :posts, posts))
          |> KsWeb.Sidenote.replace_all_marks(),
        title: assigns[:title]
      })
    )
  end

  def tag_page(tag, posts, assigns) do
    app(
      Map.merge(assigns, %{
        body: tag_file(Map.merge(assigns, %{tag: tag, posts: posts})),
        title: "#{tag.text}"
      })
    )
  end

  def tag_index(tags, assigns) do
    app(
      Map.merge(
        assigns,
        %{
          body: tag_index_file(Map.merge(assigns, %{tags: tags})),
          title: "Tags | " <> assigns[:title]
        }
      )
    )
  end

  def post_body(post, posts, assigns) do
    post_md = apply(KsWeb.Templates, post.template, [assigns])

    post_text =
      Earmark.as_html!(post_md)
      |> KsWeb.Sidenote.replace_all_marks()

    previous_post = Posts.previous_post(posts, post)
    next_post = Posts.next_post(posts, post)

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

  def post(post, posts, assigns) do
    app(Map.merge(assigns, %{body: post_body(post, posts, assigns)}))
  end

  def projects(assigns) do
    app(Map.merge(assigns, %{body: projects_file()}))
  end

  def blog(posts, assigns) do
    body = blog_file(Map.merge(assigns, %{posts: posts}))
    app(Map.merge(assigns, %{body: body, title: "Blog | " <> assigns[:title]}))
  end
end
