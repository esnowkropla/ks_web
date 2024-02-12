defmodule Mix.Tasks.Generate do
  use Mix.Task

  def run(_) do
    Mix.Task.run("app.start")

    # Put the runtime config
    KsWeb.Config.put_toml_config("config.toml")

    # Compile templates (this'll happen at compile time? hmm)
    # Generate site in public/
    IO.puts("mkdir -p public")
    File.mkdir_p("public")

    IO.puts("cp -r assets/* public/*")
    File.cp_r!("assets", "public")

    # Create index
    IO.puts("Writing index.html")

    site_assigns = %{
      title: Application.get_env(:ks_web, :title),
      build_time: DateTime.utc_now()
    }

    File.open("public/index.html", [:write, :utf8], fn file ->
      IO.write(file, KsWeb.Templates.index(site_assigns))
    end)

    # Create projects
    IO.puts("mkdir -p public/projects")
    File.mkdir_p!("public/projects")

    File.open("public/projects/index.html", [:write, :utf8], fn file ->
      IO.write(file, KsWeb.Templates.projects(site_assigns))
    end)

    # Create posts
    IO.puts("Writing posts")
    IO.puts("mkdir -p public/posts")
    File.mkdir_p!("public/posts")

    File.open("public/posts/index.html", [:write, :utf8], fn file ->
      IO.write(file, KsWeb.Templates.blog(site_assigns))
    end)

    KsWeb.Templates.posts()
    |> Enum.each(fn post ->
      post_file = "public/posts/#{post.slug}.html"
      IO.puts("\twriting #{post.title} [#{post_file}]")

      File.open(post_file, [:write, :utf8], fn file ->
        IO.write(
          file,
          KsWeb.Templates.post(post, site_assigns)
        )
      end)
    end)
  end
end
