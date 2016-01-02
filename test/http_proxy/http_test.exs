defmodule HttpProxy.HttpTest do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized
  use Plug.Test

  test "files are created in record mode" do
    File.rm_rf!(Application.get_env(:http_proxy, :export_path))
    HttpProxy.TestHelper.set_record_mode

    conn(:get, "http://localhost:8080/hoge/inu?email=neko&pass=123") |> HttpProxy.Handle.dispatch([])
    conn(:post, "http://localhost:8080/hoge/inu", "nekoneko") |> HttpProxy.Handle.dispatch([])
    conn(:put, "http://localhost:8080/hoge/inu", "nekoneko") |> HttpProxy.Handle.dispatch([])
    conn(:delete, "http://localhost:8080/hoge/inu", "nekoneko") |> HttpProxy.Handle.dispatch([])

    exported_files = case File.ls("test/example/8080/mappings") do
      {:ok, files} -> files
      {:error, _}  -> []
    end

    exported_body_files = case File.ls("test/example/8080/__files") do
      {:ok, files} -> files
      {:error, _}  -> []
    end

    assert {Enum.count(exported_files), Enum.count(exported_body_files)} == {4, 4}

    HttpProxy.TestHelper.set_play_mode
  end

  test "files are not created in play mode" do
    File.rm_rf!(Application.get_env(:http_proxy, :export_path))
    HttpProxy.TestHelper.set_play_mode

    conn(:get, "http://localhost:8080/hoge/inu?email=neko&pass=123")
    |> HttpProxy.Handle.dispatch([])

    exported_files = case File.ls("test/example/8080/mappings") do
      {:ok, files} -> files
      {:error, _}  -> []
    end
    assert Enum.count(exported_files) == 0

    exported_body_files = case File.ls("test/example/8080/__files") do
      {:ok, files} -> files
      {:error, _}  -> []
    end
    assert Enum.count(exported_body_files) == 0
  end

  test_with_params "play responses agains particular request",
    fn method, uri, expected_body ->
      HttpProxy.TestHelper.set_play_mode
      conn = conn(method, uri) |> HttpProxy.Handle.dispatch([])
      assert conn.resp_body == expected_body
    end do
      [
        {:get, "http://localhost:8080/hoge/inu?email=neko&pass=123", "{not found nil play_conn case}"},
        {:get, "http://localhost:8080/request/path", "<html>hello world</html>"},
        {:get, "http://localhost:8080/request_neko", "<html>hello world2</html>"},
        {:get, "http://localhost:8080/request_neko?email=neko&pass=123", "<html>hello world2</html>"},
        {:get, "http://localhost:8080/request_neko_fail", "{not found nil play_conn case}"},
        {:post, "http://localhost:8081/request/path", "<html>hello world 3</html>"},
        {:post, "http://localhost:8081/request/path?email=neko&pass=123", "<html>hello world 3</html>"}
      ]
  end

  test "no mached scheme" do
    assert_raise ArgumentError, "no scheme", fn ->
      conn(:get, "http://localhost:8082/")
      |> Map.put(:scheme, :ftp)
      |> HttpProxy.Handle.uri
    end
  end

  test "raise error with play and record mode" do
    HttpProxy.TestHelper.set_play_and_record_mode
    assert_raise ArgumentError, "Can't set record and play at the same time.", fn ->
      conn(:get, "http://localhost:8080/") |> HttpProxy.Handle.dispatch([])
    end
    HttpProxy.TestHelper.set_play_mode
  end

  # send real request to outside server
  test "set play and record false" do
    HttpProxy.TestHelper.set_proxy_mode
    conn = conn(:get, "http://localhost:8081/") |> HttpProxy.Handle.dispatch([])
    assert conn.status == 200
    HttpProxy.TestHelper.set_play_mode
  end

  test "start and stop http_proxy" do
    assert HttpProxy.stop == :ok
    assert HttpProxy.start == :ok
  end
end
