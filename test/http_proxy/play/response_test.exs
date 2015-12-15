defmodule HttpProxy.Play.ResponseTest do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized

  doctest HttpProxy.Play.Data

  alias HttpProxy.Play.Response

  test_with_params "regex url patterns",
    fn conn_url, url_pattern, expected_bool ->
      sample = %{ "request" => %{"method" => "GET", "path_pattern" => url_pattern, "port" => 8080},
                    "response" => %{"body" => "<html>hello world</html>", "cookies" => %{},
                       "headers" => %{"Content-Type" => "text/html; charset=UTF-8",
                         "Server" => "GFE/2.0"}, "status_code" => 200}}
      assert Response.pattern(conn_url, sample["request"]) == expected_bool
    end do
      [
        "match simple url":     {"neko", ~r/neko/, true},
        "do not match string":  {"path/to/string", ~r/pathtostring/, false},
        "match regex case":     {"path/to/string", ~r/\Apath.*string\z/, true}
      ]
  end
end
