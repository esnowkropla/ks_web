defmodule KsWeb.PostsTest do
  use ExUnit.Case

  import KsWeb.Posts
  alias KsWeb.Posts.Post
  alias KsWeb.Tags.Tag

  @meta_text ~s(\npublished_at = "2017-07-10T09:48:29-04:00"\ntags = ["tag1", "tag2"]\n)

  describe "get_tags_from_tag_list" do
    setup [:tag_list]

    test "it gets tags from the string", %{tag_list: tag_list} do
      assert get_tags_from_tag_list(tag_list) == ~w(tag1 tag2)
    end
  end

  describe "get_tags" do
    setup [:meta_text]

    test "it gets tags from the meta text", %{meta_text: meta_text} do
      assert get_tags(meta_text) == ~w(tag1 tag2)
    end
  end

  describe "process meta" do
    setup [:meta_text]

    test "processes tag lists", %{meta_text: meta_text} do
      meta = process_meta(meta_text)
      assert meta.tags == ~w[tag1 tag2]
    end

    test "gets published_at", %{meta_text: meta_text} do
      meta = process_meta(meta_text)
      assert meta.published_at == ~U[2017-07-10 13:48:29+00:00]
    end
  end

  describe "posts_for_tag/2" do
    setup [:posts]

    test "it filters posts based on the tag", %{posts: posts} do
      assert posts_for_tag(posts, %Tag{text: "tag1"}) == [
               %Post{tags: ["tag1"]},
               %Post{tags: ["tag3", "tag1"]}
             ]
    end
  end

  defp posts(_) do
    %{
      posts: [
        %Post{tags: ["tag1"]},
        %Post{tags: ["tag2"]},
        %Post{tags: ["tag3", "tag1"]},
        %Post{tags: []}
      ]
    }
  end

  defp meta_text(_) do
    %{meta_text: @meta_text}
  end

  defp tag_list(_) do
    %{tag_list: ~s(["tag1", "tag2"])}
  end
end
