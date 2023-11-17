defmodule KsWeb.Templates do
  require EEx

  paths = Path.wildcard("lib/ks_web/templates/*.md.eex")
  paths_hash = :erlang.md5(paths)

  for path <- paths do
    @external_resource path
  end

  def __mix_recompile__?() do
    Path.wildcard("lib/ks_web/templates/*.md.eex") |> :erlang.md5() != unquote(paths_hash)
  end

  Module.register_attribute(__MODULE__, :posts, accumulate: true)

  File.ls!("lib/ks_web/templates")
  |> Enum.each(fn file ->
    post = KsWeb.Posts.process_post(file)
    @posts post

    EEx.function_from_string(:def, post.template, post.content, [:assigns])
  end)

  def posts, do: Enum.reverse(@posts)
end
