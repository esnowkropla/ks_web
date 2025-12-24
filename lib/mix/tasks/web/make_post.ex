defmodule Mix.Tasks.Web.MakePost do
  @shortdoc "Generate a new skeleton post"

  use Mix.Task

  def run(args) do
    if args == [] or "-h" in args or "--help" in args do
      print_usage()
    else
      Mix.Task.run("app.start")

      {switches, [post_title], _} =
        OptionParser.parse(
          args,
          strict: [tags: :string, published: :boolean]
        )

      tags = get_tags(switches)
      published = Keyword.get(switches, :published, false)
      file_name = "#{KsWeb.Sluggify.slug!(post_title)}.md.eex"
      path = "templates/posts/#{file_name}"

      content = post_template(post_title, tags, published)

      if File.exists?(path) do
        IO.puts(:stderr, "The file #{path} already exists, aborting")
        exit(1)
      else
        IO.puts("Creating post skeleton ...")
        IO.puts("title: #{post_title}")
        IO.puts("tags: #{tags}")
        IO.puts("path: #{path}")

        File.open(path, [:write, :utf8], fn file ->
          IO.write(file, content)
        end)

        IO.puts("done")
      end
    end
  end

  defp print_usage do
    IO.puts("""
    Usage: mix web.make_post [OPTIONS] POST_TITLE

    Generate a new skeleton post with the given title.

    Arguments:
      POST_TITLE              The title of the post to create

    Options:
      --tags TAGS             Comma-separated list of tags
      --published             Mark the post as published (sets published_at)
      -h, --help              Print this help message

    Examples:
      mix web.make_post "My First Post"
      mix web.make_post --tags "elixir,web" "My First Post"
      mix web.make_post --tags "elixir,web" --published "My First Post"
    """)
  end

  defp post_template(post_title, tags, published) do
    ~s"""
    +++
    #{header(post_title, tags, published)}
    +++
    """
  end

  defp header(post_title, tags, published) do
    base = ~s"""
    created_at = "#{DateTime.utc_now()}"
    tags = [#{tags}]
    title = "#{post_title}"
    """

    if(published) do
      ~s(#{base}published_at = "#{DateTime.utc_now()}"\n)
    else
      base
    end
    |> String.trim_trailing()
  end

  defp get_tags(switches) do
    Keyword.get(switches, :tags, "")
    |> String.split(",")
    |> Enum.sort()
    |> Enum.map(&~s("#{&1}"))
    |> Enum.join(", ")
  end
end
