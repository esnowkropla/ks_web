defmodule KsWeb.Generation.Posts do
  import KsWeb.Templates, only: [blog: 2, post: 3]

  def write_index(posts, base_dir, site_assigns, tags) do
    IO.puts("mkdir -p #{base_dir}/posts")
    File.mkdir_p!("#{base_dir}/posts")

    File.open("#{base_dir}/posts/index.html", [:write, :utf8], fn file ->
      IO.write(file, blog(posts, Map.merge(site_assigns, %{tags: tags})))
    end)
  end

  def write_each(posts, base_dir, site_assigns) do
    posts
    |> Enum.each(fn post ->
      post_file = "#{base_dir}/posts/#{post.slug}.html"
      IO.puts("\twriting #{post.title} [#{post_file}]")

      File.open(post_file, [:write, :utf8], fn file ->
        IO.write(
          file,
          post(post, posts, site_assigns)
        )
      end)
    end)
  end
end
