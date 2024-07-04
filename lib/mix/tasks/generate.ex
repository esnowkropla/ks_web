defmodule Mix.Tasks.Generate do
  @shortdoc "Generate the site"

  alias KsWeb.Posts

  use Mix.Task

  def run(args) do
    Mix.Task.run("app.start")

    base_dir =
      case args do
        [dir | _] -> dir
        [] -> "public"
      end

    IO.puts("writing to '#{base_dir}' as base_dir")

    # Put the runtime config
    KsWeb.Config.put_toml_config("config.toml")

    # Compile templates (this'll happen at compile time? hmm)
    # Generate site in public/
    IO.puts("mkdir -p #{base_dir}")
    File.mkdir_p(base_dir)

    IO.puts("cp -r assets/* #{base_dir}/*")
    File.cp_r!("assets", base_dir)

    # Create index
    IO.puts("Writing index.html")

    site_assigns = %{
      title: Application.get_env(:ks_web, :title),
      build_time: DateTime.utc_now()
    }

    File.open("#{base_dir}/index.html", [:write, :utf8], fn file ->
      IO.write(file, KsWeb.Templates.index(site_assigns))
    end)

    # Create projects
    IO.puts("mkdir -p #{base_dir}/projects")
    File.mkdir_p!("#{base_dir}/projects")

    File.open("#{base_dir}/projects/index.html", [:write, :utf8], fn file ->
      IO.write(file, KsWeb.Templates.projects(site_assigns))
    end)

    posts = KsWeb.Templates.published_posts()
    tags = KsWeb.Tags.make_tags(posts)

    # Create posts
    IO.puts("Writing posts")
    IO.puts("mkdir -p #{base_dir}/posts")
    File.mkdir_p!("#{base_dir}/posts")

    File.open("#{base_dir}/posts/index.html", [:write, :utf8], fn file ->
      IO.write(file, KsWeb.Templates.blog(Map.merge(site_assigns, %{tags: tags})))
    end)

    posts
    |> Enum.each(fn post ->
      post_file = "#{base_dir}/posts/#{post.slug}.html"
      IO.puts("\twriting #{post.title} [#{post_file}]")

      File.open(post_file, [:write, :utf8], fn file ->
        IO.write(
          file,
          KsWeb.Templates.post(post, site_assigns)
        )
      end)
    end)

    # Writing tags
    IO.puts("Writing tags")
    IO.puts("mkdir -p #{base_dir}/tags")
    File.mkdir_p!("#{base_dir}/tags")

    File.open("#{base_dir}/tags/index.html", [:write, :utf8], fn file ->
      IO.write(file, KsWeb.Templates.tag_index(tags, site_assigns))
    end)

    Enum.each(tags, fn tag ->
      target = "#{base_dir}/tags/#{tag.slug}"
      IO.puts("mkdir -p #{target}")
      File.mkdir_p!(target)

      File.open("#{target}/index.html", [:write, :utf8], fn file ->
        IO.write(
          file,
          KsWeb.Templates.tag_page(
            tag,
            Posts.posts_for_tag(posts, tag),
            site_assigns
          )
        )
      end)
    end)

    # Writing Feed
    IO.puts("Writing #{base_dir}/feed.atom")

    File.open("#{base_dir}/feed.atom", [:write, :utf8], fn file ->
      host = Application.get_env(:ks_web, :host)
      IO.write(file, KsWeb.Feed.build_feed(KsWeb.Templates.published_posts(), host))
    end)

    # Write CNAME for github pages
    IO.puts("Writing CNAME")

    File.open("#{base_dir}/CNAME", [:write, :utf8], fn file ->
      IO.write(file, Application.get_env(:ks_web, :cname))
    end)
  end
end
