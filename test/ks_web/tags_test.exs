defmodule KsWeb.TagsTest do
  use ExUnit.Case

  alias KsWeb.Posts.Post
  alias KsWeb.Tags.Tag
  import KsWeb.Tags

  describe "get_tags/1" do
    setup [:posts]

    test "it gets tags from lists of posts", %{posts: posts} do
      assert get_tags(posts) == ~w[tag1 tag2]
    end

    test "it dedups tags", %{posts: posts} do
      posts = posts ++ [%Post{tags: ["tag1"]}]
      assert get_tags(posts) == ~w[tag1 tag2]
    end
  end

  describe "tags_with_counts/1" do
    setup [:posts]

    test "it returns a sorted list of {tag, count} pairs", %{posts: posts} do
      assert tags_with_counts(posts) == [{"tag1", 1}, {"tag2", 1}]
    end

    test "it sorts on tag count desc", %{posts: posts} do
      posts = posts ++ [%Post{tags: ["tag2"]}]
      assert tags_with_counts(posts) == [{"tag2", 2}, {"tag1", 1}]
    end
  end

  describe "make_tags/1" do
    setup :posts

    test "it returns a sorted list of tags", %{posts: posts} do
      assert make_tags(posts) == [
               %Tag{text: "tag1", count: 1, slug: "tag1"},
               %Tag{text: "tag2", count: 1, slug: "tag2"}
             ]
    end
  end

  defp posts(_env) do
    %{posts: [%Post{tags: ["tag1"]}, %Post{tags: ["tag2"]}]}
  end
end
