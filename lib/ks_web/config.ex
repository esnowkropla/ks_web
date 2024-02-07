defmodule KsWeb.Config do
  def put_toml_config(path) do
    path
    |> File.read!()
    |> Toml.decode!(keys: :atoms)
    |> Enum.each(fn {key, value} ->
      Application.put_env(:ks_web, key, value)
    end)
  end
end
