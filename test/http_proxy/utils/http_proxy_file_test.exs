defmodule HttpProxy.Utils.File.Test do
  use ExUnit.Case, async: true
  use Plug.Test
  
  alias HttpProxy.Utils.File, as: HttpProxyFile

  test "check path generations" do
    conn = conn(:get, "http://localhost:8080/")

    assert HttpProxyFile.gen_export_path(conn) == "example/8080"
    assert HttpProxyFile.response_path == "__files"
    assert HttpProxyFile.mapping_path == "mappings"
  end
end
