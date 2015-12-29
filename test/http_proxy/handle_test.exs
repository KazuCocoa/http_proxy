defmodule HttpProxy.HandleTest do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized
  use Plug.Test

  doctest HttpProxy.Data
  doctest HttpProxy.Handle

  test_with_params "should convert urls",
    fn local_url, proxied_url ->
      conn = conn(:get, local_url)
      assert HttpProxy.Handle.uri(conn) == proxied_url
    end do
      [
        "root":  {"http://localhost:8080/", "http://google.com/" },
        "path":  {"https://localhost:8081/neko", "http://neko.com/neko"},
        "query": {"http://localhost:8081/neko?hoge=1", "http://neko.com/neko?hoge=1"},
        "no proxy with http":  {"http://localhost:8082/", "http://localhost/" },
        "no proxy with https":  {"https://localhost:8082/", "https://localhost/" },
      ]
  end
end
