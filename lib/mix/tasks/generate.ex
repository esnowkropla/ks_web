defmodule Mix.Tasks.Generate do
  use Mix.Task

  def run(_) do
    Mix.Task.run("app.start")

    # Compile templates (this'll happen at compile time? hmm)
    # Generate site in public/
    IO.puts("mkdir -p public")
    File.mkdir_p("public")

    File.open("public/index.html", [:write], fn file ->
      IO.write(file, KsWeb.Templates.index(%{}))
    end)
  end
end
