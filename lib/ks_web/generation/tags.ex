defmodule KsWeb.Generation.Tags do
  import KsWeb.Posts, only: [posts_for_tag: 2]

  def write_index(base_dir, tags, site_assigns) do
    IO.puts("mkdir -p #{base_dir}/tags")
    File.mkdir_p!("#{base_dir}/tags")

    File.open("#{base_dir}/tags/index.html", [:write, :utf8], fn file ->
      IO.write(file, KsWeb.Templates.tag_index(tags, site_assigns))
    end)
  end

  def write_each(base_dir, tags, posts, site_assigns) do
    Enum.each(tags, fn tag ->
      target = "#{base_dir}/tags/#{tag.slug}"
      IO.puts("mkdir -p #{target}")
      File.mkdir_p!(target)

      File.open("#{target}/index.html", [:write, :utf8], fn file ->
        IO.write(
          file,
          KsWeb.Templates.tag_page(
            tag,
            posts_for_tag(posts, tag),
            site_assigns
          )
        )
      end)
    end)
  end
end
