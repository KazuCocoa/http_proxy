defmodule HttpProxy.Play.ResponseTest do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized

  doctest HttpProxy.Play.Data

  alias HttpProxy.Play.Response
  alias HttpProxy.Play.Paths

  test_with_params "regex url patterns",
    fn conn_url, url_pattern, expected_bool ->
      sample = %{ "request" => %{"method" => "GET", "path_pattern" => url_pattern, "port" => 8080},
                    "response" => %{"body" => "<html>hello world</html>", "cookies" => %{},
                       "headers" => %{"Content-Type" => "text/html; charset=UTF-8",
                         "Server" => "GFE/2.0"}, "status_code" => 200}}
      assert Response.pattern(conn_url, sample["request"]) == expected_bool
    end do
      [
        "match simple url":     {"neko", "neko", true},
        "do not match string":  {"path/to/string", "pathtostring", false},
        "match regex case":     {"path/to/string", "path.*string", true}
      ]
  end

  test "HttpProxy.Play.Response#has_path_pattern? is true" do
    sample = %{ "request" => %{"method" => "GET", "path_pattern" => "example_pattern", "port" => 8080},
                  "response" => %{"body" => "<html>hello world</html>", "cookies" => %{},
                     "headers" => %{"Content-Type" => "text/html; charset=UTF-8",
                       "Server" => "GFE/2.0"}, "status_code" => 200}}
    assert Response.has_path_pattern?(sample) == true
  end

  test "HttpProxy.Play.Response#has_path_pattern? is false" do
    sample = %{ "request" => %{"method" => "GET", "path" => "example_pattern", "port" => 8080},
                  "response" => %{"body" => "<html>hello world</html>", "cookies" => %{},
                     "headers" => %{"Content-Type" => "text/html; charset=UTF-8",
                       "Server" => "GFE/2.0"}, "status_code" => 200}}
    assert Response.has_path_pattern?(sample) == false
  end

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

  test "HttpProxy.Play.Paths#has_path_pattern? is true" do
    path = "/request_ok_case_neko"
    assert Paths.has_path_pattern?(path) == "\\A/request.*neko\\z"
  end

  test "HttpProxy.Play.Paths#has_path_pattern? is false" do
    path = "/request"
    assert Paths.has_path_pattern?(path) == nil
  end

end
