defmodule HttpProxy.Utils.FileTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias HttpProxy.Utils.File, as: HttpProxyFile

  doctest HttpProxy.Utils.File
  doctest HttpProxy.Utils

  test "check read json files" do
    json_test_dir = "test/data/mappings"
    json_file_path = ["test/data/mappings/sample.json", "test/data/mappings/sample2.json", "test/data/mappings/sample3.json"]
    expected_json = %{"request" => %{"path" => "/request/path", "port" => 8080, "method" => "GET"},
              "response" => %{"body" => "<html>hello world</html>", "cookies" => %{},
                "headers" => %{"Content-Type" => "text/html; charset=UTF-8", "Server" => "GFE/2.0"}, "status_code" => 200}}

    assert json_file_path == HttpProxyFile.json_files!(json_test_dir) |> Enum.sort
    assert {:ok, expected_json} == HttpProxyFile.read_json_file("test/data/mappings/sample.json")
  end

  test "failed to read json files" do
    json_test_dir = "test/data/map"
    json_file_path = "test/data/mappings/sample"

    assert {:error, :enoent} == HttpProxyFile.json_files(json_test_dir)
    assert {:error, :enoent} == HttpProxyFile.read_json_file(json_file_path)
  end
end
