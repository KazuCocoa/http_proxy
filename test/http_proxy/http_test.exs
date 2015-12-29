defmodule HttpProxy.HttpTest do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized
  use Plug.Test

  defp set_play_mode do
    Application.put_env :http_proxy, :record, false
    Application.put_env :http_proxy, :play, true
  end

  defp set_record_mode do
    Application.put_env :http_proxy, :record, true
    Application.put_env :http_proxy, :play, false
  end

  test "files are created in record mode" do
    File.rm_rf!(Application.get_env(:http_proxy, :export_path))
    set_record_mode

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

    set_play_mode
  end

  test "files are not created in play mode" do
    File.rm_rf!(Application.get_env(:http_proxy, :export_path))
    set_play_mode

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
      set_play_mode
      conn = conn(method, uri) |> HttpProxy.Handle.dispatch([])
      assert conn.resp_body == expected_body
    end do
      [
        {:get, "http://localhost:8080/hoge/inu?email=neko&pass=123", "<html>not found nil play_conn case</html>"},
        {:get, "http://localhost:8080/request/path", "<html>hello world</html>"},
        {:get, "http://localhost:8080/request_neko", "<html>hello world2</html>"},
        {:get, "http://localhost:8080/request_neko?email=neko&pass=123", "<html>hello world2</html>"},
        {:get, "http://localhost:8080/request_neko_fail", "<html>not found nil play_conn case</html>"},
        {:post, "http://localhost:8081/request/path", "<html>hello world 3</html>"},
        {:post, "http://localhost:8081/request/path?email=neko&pass=123", "<html>hello world 3</html>"}
      ]
  end

  test "start and stop http_proxy" do
    assert HttpProxy.stop == :ok
    assert HttpProxy.start == :ok
  end
end
