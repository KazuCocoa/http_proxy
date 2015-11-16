defmodule HttpProxyFileTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "check path generations" do
    conn = conn(:get, "http://localhost:8080/")

    assert HttpProxy.File.gen_export_path(conn) == "example/8080"
    assert HttpProxy.File.response_path == "__files"
    assert HttpProxy.File.mapping_path == "mappings"
  end
end
