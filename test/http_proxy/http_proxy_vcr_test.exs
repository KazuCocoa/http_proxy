defmodule HttpProxyVerTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  use Plug.Test

  alias HttpProxy.Handle, as: HttpProxyHandle

  @tag skip: "make this test flaky other tests"
  test "get request" do
    use_cassette "httpoison_get" do
      con = conn(:get, "http://localhost:8080/")
      :hackney.request :get, HttpProxyHandle.uri(con), con.req_headers, [], []
    end
  end
end
