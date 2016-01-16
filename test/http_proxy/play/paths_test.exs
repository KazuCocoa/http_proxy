defmodule HttpProxy.Play.PathsTest do
  use ExUnit.Case, async: false
  use ExUnit.Parameterized

  doctest HttpProxy.Play.Data
  doctest HttpProxy.Play.Paths

  alias HttpProxy.Play.Paths

  test_with_params "HttpProxy.Play.Paths#has_path?",
    fn path, expected_path ->
      assert Paths.has_path?(path) == expected_path
    end do
      [
        {"/request/path/neko", nil},
        {"/request/path", "/request/path"},
        {"%E3%81%82%20", nil}
      ]
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
