defmodule HttpProxy.Play.ResponseTest do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized

  doctest HttpProxy.Play.Data

  alias HttpProxy.Play.Paths

  test "HttpProxy.Play.Paths#play_paths" do
    expected = %Paths{path_patterns: ["\\A/request.*neko\\z"],
                paths: ["/request/path", "/request/path"]}
    assert Paths.__struct__ == expected
    assert Paths.paths == ["/request/path", "/request/path"]
    assert Paths.path_patterns == ["\\A/request.*neko\\z"]
  end

  test "HttpProxy.Play.Paths#has_path? is true" do
    path = "/request/path"
    assert Paths.has_path?(path) == "/request/path"
  end

  test "HttpProxy.Play.Paths#has_path? is false" do
    path = "/request/path/neko"
    assert Paths.has_path?(path) == nil
  end

  test_with_params "HttpProxy.Play.Paths#has_path_pattern?",
    fn path, expected_pattern ->
      assert Paths.has_path_pattern?(path) == expected_pattern
    end do
      [
        {"/request_ok_case_neko", "\\A/request.*neko\\z"},
        {"/request_nekofail", nil},
        {"/request/neko", "\\A/request.*neko\\z"},
        {"/request", nil}
      ]
  end
end
