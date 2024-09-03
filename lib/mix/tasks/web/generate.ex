defmodule Mix.Tasks.Web.Generate do
  @shortdoc "Generate the site"

  import KsWeb.Tags, only: [make_tags: 1]

  alias KsWeb.Generation.Posts
  alias KsWeb.Generation.Tags

  use Mix.Task

  def run(args) do
    Mix.Task.run("app.start")

    base_dir =
      case args do
        [dir | _] -> dir
        [] -> "public"
      end

    posts = KsWeb.Posts.published_posts()
    tags = make_tags(posts)

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
      IO.write(file, KsWeb.Templates.index(posts, site_assigns))
    end)

    # Create projects
    IO.puts("mkdir -p #{base_dir}/projects")
    File.mkdir_p!("#{base_dir}/projects")

    File.open("#{base_dir}/projects/index.html", [:write, :utf8], fn file ->
      IO.write(file, KsWeb.Templates.projects(site_assigns))
    end)

    # Create posts
    IO.puts("Writing posts")
    Posts.write_index(posts, base_dir, site_assigns, tags)
    Posts.write_each(posts, base_dir, site_assigns)

    # Writing tags
    IO.puts("Writing tags")
    Tags.write_index(base_dir, tags, site_assigns)
    Tags.write_each(base_dir, tags, posts, site_assigns)

    # Writing Feed
    IO.puts("Writing #{base_dir}/feed.atom")

    File.open("#{base_dir}/feed.atom", [:write, :utf8], fn file ->
      assigns = Map.put(site_assigns, :host, Application.get_env(:ks_web, :host))
      IO.write(file, KsWeb.Feed.build_feed(posts, assigns))
    end)

    # Write CNAME for github pages
    IO.puts("Writing CNAME")

    File.open("#{base_dir}/CNAME", [:write, :utf8], fn file ->
      IO.write(file, Application.get_env(:ks_web, :cname))
    end)
  end
end
