defmodule KsWeb.Posts.Post do
  defstruct [:template, :path, :created_at, :published_at, :title, :tags, :content]
end
