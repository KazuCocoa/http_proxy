defmodule HttpProxy.Play.ResponseTest do
  use ExUnit.Case, async: false
  use ExUnit.Parameterized

  doctest HttpProxy.Play.Response

  alias HttpProxy.Play.Response

  test "HttpProxy.Play.Response#play_responses with play mode" do
    HttpProxy.TestHelper.set_play_mode

    expected = ["get_8080/request/path": %{"request" => %{"method" => "GET", "path" => "/request/path", "port" => 8080},
              "response" => %{"body" => "<html>hello world</html>", "cookies" => %{},
                "headers" => %{"Content-Type" => "text/html; charset=UTF-8", "Server" => "GFE/2.0"}, "status_code" => 200}},
            "get_8080\\A/request.*neko\\z": %{"request" => %{"method" => "GET", "path_pattern" => "\\A/request.*neko\\z",
                "port" => 8080},
              "response" => %{"body_file" => "test/data/__files/example.json", "cookies" => %{},
                "headers" => %{"Content-Type" => "text/html; charset=UTF-8", "Server" => "GFE/2.0"}, "status_code" => 200}},
            "post_8081/request/path": %{"request" => %{"method" => "POST", "path" => "/request/path", "port" => 8081},
              "response" => %{"body" => "<html>hello world 3</html>", "cookies" => %{},
                "headers" => %{"Content-Type" => "text/html; charset=UTF-8", "Server" => "GFE/2.0"}, "status_code" => 201}}]

    assert Response.play_responses == expected
  end

  test "HttpProxy.Play.Response#play_responses with record mode" do
    HttpProxy.TestHelper.set_record_mode

    expected = []

    assert Response.play_responses == expected
  end

end
