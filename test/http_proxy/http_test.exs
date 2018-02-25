defmodule HttpProxy.HttpTest do
  use ExUnit.Case, async: false

  use ExUnit.Parameterized
  use Plug.Test

  alias HttpProxy.TestHelper, as: TestHelper
  alias HttpProxy.Handle, as: HttpProxyHandle

  test "files are created in record mode" do
    File.rm_rf!(Application.get_env(:http_proxy, :export_path))
    TestHelper.set_record_mode()

    HttpProxyHandle.dispatch(conn(:get, "http://localhost:8080/hoge/inu?email=neko&pass=123"), [])
    HttpProxyHandle.dispatch(conn(:post, "http://localhost:8080/hoge/inu", "nekoneko"), [])
    HttpProxyHandle.dispatch(conn(:put, "http://localhost:8080/hoge/inu", "nekoneko"), [])
    HttpProxyHandle.dispatch(conn(:delete, "http://localhost:8080/hoge/inu", "nekoneko"), [])

    exported_files =
      case File.ls("test/example/8080/mappings") do
        {:ok, files} -> files
        {:error, _} -> []
      end

    exported_body_files =
      case File.ls("test/example/8080/__files") do
        {:ok, files} -> files
        {:error, _} -> []
      end

    assert {Enum.count(exported_files), Enum.count(exported_body_files)} == {4, 4}

    TestHelper.set_play_mode()
  end

  test "files are not created in play mode" do
    File.rm_rf!(Application.get_env(:http_proxy, :export_path))
    TestHelper.set_play_mode()

    HttpProxyHandle.dispatch(conn(:get, "http://localhost:8080/hoge/inu?email=neko&pass=123"), [])

    exported_files =
      case File.ls("test/example/8080/mappings") do
        {:ok, files} -> files
        {:error, _} -> []
      end

    assert Enum.count(exported_files) == 0

    exported_body_files =
      case File.ls("test/example/8080/__files") do
        {:ok, files} -> files
        {:error, _} -> []
      end

    assert Enum.count(exported_body_files) == 0
  end

  test_with_params "play responses agains particular request", fn method, uri, expected_body ->
    TestHelper.set_play_mode()
    conn = HttpProxyHandle.dispatch(conn(method, uri), [])
    assert conn.resp_body == expected_body
  end do
    [
      {:get, "http://localhost:8080/hoge/inu?email=neko&pass=123",
       "{not found nil play_conn case}"},
      {:get, "http://localhost:8080/request/path", "<html>hello world</html>"},
      {:get, "http://localhost:8080/request_neko", "{\n  \"example\": \"data\"\n}\n"},
      {:get, "http://localhost:8080/request_neko?email=neko&pass=123",
       "{\n  \"example\": \"data\"\n}\n"},
      {:get, "http://localhost:8080/request_neko_fail", "{not found nil play_conn case}"},
      {:post, "http://localhost:8081/request/path", "<html>hello world 3</html>"},
      {:post, "http://localhost:8081/request/path?email=neko&pass=123",
       "<html>hello world 3</html>"}
    ]
  end

  test "no mached scheme" do
    assert_raise ArgumentError, "no scheme", fn ->
      conn = conn(:get, "http://localhost:8082/")

      conn
      |> Map.put(:scheme, :ftp)
      |> HttpProxyHandle.uri()
    end
  end

  test "raise error with play and record mode" do
    TestHelper.set_play_and_record_mode()

    assert_raise ArgumentError, "Can't set record and play at the same time.", fn ->
      HttpProxyHandle.dispatch(conn(:get, "http://localhost:8080/"), [])
    end

    TestHelper.set_play_mode()
  end

  # send real request to outside server
  test "set play and record false" do
    TestHelper.set_proxy_mode()
    conn = HttpProxyHandle.dispatch(conn(:get, "http://localhost:8081/"), [])
    assert conn.status == 200
    TestHelper.set_play_mode()
  end

  test "start and stop http_proxy" do
    assert HttpProxy.stop() == :ok
    assert HttpProxy.start() == :ok
  end

  describe "HttpProxy.Play.Response" do
    alias HttpProxy.Play.Response

    test "#play_responses with play mode" do
      TestHelper.set_play_mode()

      expected = [
        "get_8080/request/path": %{
          "request" => %{"method" => "GET", "path" => "/request/path", "port" => 8080},
          "response" => %{
            "body" => "<html>hello world</html>",
            "cookies" => %{},
            "headers" => %{"Content-Type" => "text/html; charset=UTF-8", "Server" => "GFE/2.0"},
            "status_code" => 200
          }
        },
        "get_8080\\A/request.*neko\\z": %{
          "request" => %{
            "method" => "GET",
            "path_pattern" => "\\A/request.*neko\\z",
            "port" => 8080
          },
          "response" => %{
            "body_file" => "test/data/__files/example.json",
            "cookies" => %{},
            "headers" => %{"Content-Type" => "text/html; charset=UTF-8", "Server" => "GFE/2.0"},
            "status_code" => 200
          }
        },
        "post_8081/request/path": %{
          "request" => %{"method" => "POST", "path" => "/request/path", "port" => 8081},
          "response" => %{
            "body" => "<html>hello world 3</html>",
            "cookies" => %{},
            "headers" => %{"Content-Type" => "text/html; charset=UTF-8", "Server" => "GFE/2.0"},
            "status_code" => 201
          }
        }
      ]

      assert Response.play_responses()[:"get_8080/request/path"] ==
               expected[:"get_8080/request/path"]

      assert Response.play_responses()[:"get_8080\\A/request.*neko\\z"] ==
               expected[:"get_8080\\A/request.*neko\\z"]

      assert Response.play_responses()[:"post_8081/request/path"] ==
               expected[:"post_8081/request/path"]
    end

    test "HttpProxy.Play.Response#play_responses with record mode" do
      TestHelper.set_record_mode()

      expected = []

      assert Response.play_responses() == expected
    end
  end
end
