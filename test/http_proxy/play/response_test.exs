defmodule HttpProxy.Play.ResponseTest do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized

  doctest HttpProxy.Play.Data

  alias HttpProxy.Play.Response

  test_with_params "regex url patterns",
    fn conn_url, url_pattern, expected_bool ->
      assert Response.pattern(conn_url, %{url_pattern: url_pattern}) == expected_bool
    end do
      [
        "match simple url":     {"neko", ~r/neko/, true},
        "do not match string":  {"path/to/string", ~r/pathtostring/, false},
        "match regex case":     {"path/to/string", ~r/\Apath.*string\z/, true}
      ]
  end
end
