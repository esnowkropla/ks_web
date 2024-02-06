defmodule Mix.Tasks.Generate do
  use Mix.Task

  def run(_) do
    Mix.Task.run("app.start")

    # Compile templates (this'll happen at compile time? hmm)
    # Generate site in public/
    IO.puts("mkdir -p public")
    File.mkdir_p("public")

    IO.puts("cp -r assets/* public/*")
    File.cp_r!("assets", "public")

    # Create index
    IO.puts("Writing index.html")

    File.open("public/index.html", [:write], fn file ->
      IO.write(file, KsWeb.Templates.index(%{}))
    end)

    # Create posts
    IO.puts("Writing posts")

    KsWeb.Templates.posts()
    |> Enum.each(fn post ->
      IO.puts("\t#{post.title}")
    end)
  end
end
