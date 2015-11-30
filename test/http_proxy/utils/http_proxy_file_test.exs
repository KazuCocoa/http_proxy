defmodule HttpProxy.Utils.File.Test do
  use ExUnit.Case, async: true
  use Plug.Test

  alias HttpProxy.Utils.File, as: HttpProxyFile

  test "check path generations" do
    conn = conn(:get, "http://localhost:8080/")

    assert HttpProxyFile.get_export_path == "example"
    assert HttpProxyFile.get_export_path(conn) == "example/8080"
    assert HttpProxyFile.get_response_path == "test/data/__files"
    assert HttpProxyFile.get_mapping_path == "test/data/mappings"
  end
end
