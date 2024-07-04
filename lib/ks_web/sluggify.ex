defmodule KsWeb.Sluggify do
  def slug(text) do
    result =
      text
      |> String.replace(~r/[^\w\s-]/, "")
      |> String.replace(~r/\s+/, "-")
      |> String.downcase()

    case result do
      "" -> {:error, "No result"}
      text -> {:ok, text}
    end
  end

  def slug!(text) do
    case slug(text) do
      {:error, e} -> raise e
      {:ok, text} -> text
    end
  end
end
