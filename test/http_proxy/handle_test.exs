defmodule HttpProxy.HandleTest do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized
  use Plug.Test

  alias HttpProxy.Handle, as: HttpProxyHandle

  doctest HttpProxy.Data
  doctest HttpProxy.Handle

  test_with_params "should convert urls",
    fn local_url, proxied_url ->
      conn = conn(:get, local_url)
      assert HttpProxyHandle.uri(conn) == proxied_url
    end do
      [
        "root":  {"http://localhost:8080/", "http://google.com/"},
        "path":  {"https://localhost:8081/neko", "http://www.google.co.jp/neko"},
        "query": {"http://localhost:8081/neko?hoge=1", "http://www.google.co.jp/neko?hoge=1"},
        "no proxy with http":  {"http://localhost:8082/", "http://localhost/"},
        "no proxy with https":  {"https://localhost:8082/", "https://localhost/"},
      ]
  end
end
