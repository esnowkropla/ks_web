defmodule KsWeb.Sluggify do
  def slug(text) do
    result =
      text
      |> String.replace(~r/[^\w\s]/, "")
      |> String.replace(~r/\s+/, "-")
      |> String.downcase()

    case result do
      "" -> {:err, "No result"}
      text -> {:ok, text}
    end
  end
end
