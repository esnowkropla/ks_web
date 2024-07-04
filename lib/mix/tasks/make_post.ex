defmodule Mix.Tasks.MakePost do
  @shortdoc "Generate a new skeleton post"

  use Mix.Task

  def run([post_name | _]) do
    Mix.Task.run("app.start")

    content = ~s(
      +++
      created_at = "#{DateTime.utc_now()}"
      +++
    )

    IO.puts(content)
  end
end
