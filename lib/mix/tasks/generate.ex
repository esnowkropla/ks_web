defmodule Mix.Tasks.Serve do
  use Mix.Task

  def run(args) do
    Mix.Task.run("app.start")

    # Compile templates (this'll happen at compile time? hmm)
    # Generate site in public/
  end
end
