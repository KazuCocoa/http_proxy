defmodule HttpProxy.Test do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized
  use Plug.Test

  doctest HttpProxy.Data

  test "check subversion tree" do
    pid = Process.whereis HttpProxy.Supervisor
    assert pid != nil

    children = Supervisor.which_children HttpProxy.Supervisor
    {id, _, _, modules} = hd(children)

    assert Enum.count(children) == 2
    assert id == :"HttpProxy.Handle8080"
    assert modules == [HttpProxy.Handle]
  end

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

  # TODO: prepare record = true case
  test "send request and get response" do
    File.rm_rf!(Application.get_env(:http_proxy, :export_path))

    conn(:get, "http://localhost:8080/hoge/inu?email=neko&pass=123")
    |> HttpProxy.Handle.dispatch("")

    conn(:post, "http://localhost:8080/hoge/inu", "nekoneko")
    |> HttpProxy.Handle.dispatch("")

    conn(:put, "http://localhost:8080/hoge/inu", "nekoneko")
    |> HttpProxy.Handle.dispatch("")

    conn(:delete, "http://localhost:8080/hoge/inu", "nekoneko")
    |> HttpProxy.Handle.dispatch("")

    exported_files = case File.ls("test/example/8080") do
      {:ok, files} -> files
      {:error, _}  -> []
    end
    assert Enum.count(exported_files) == 0
  end

  test "format of play_response" do
    expected = ["get_8080/request/path": %{"request" => %{"method" => "GET",
                     "path" => "request/path", "port" => 8080},
                   "response" => %{"body" => "<html>hello world</html>", "cookies" => %{},
                     "headers" => %{"Content-Type" => "text/html; charset=UTF-8",
                       "Server" => "GFE/2.0"}, "status_code" => 200}},
                 "post_8080/request/path2": %{"request" => %{"method" => "POST",
                     "path" => "request/path2", "port" => 8080},
                   "response" => %{"body" => "<html>hello world2</html>", "cookies" => %{},
                     "headers" => %{"Content-Type" => "text/html; charset=UTF-8",
                       "Server" => "GFE/2.0"}, "status_code" => 200}},
                 "get_8081/request/path": %{"request" => %{"method" => "GET",
                     "path" => "request/path", "port" => 8081},
                   "response" => %{"body" => "<html>hello world 3</html>", "cookies" => %{},
                     "headers" => %{"Content-Type" => "text/html; charset=UTF-8",
                       "Server" => "GFE/2.0"}, "status_code" => 200}}]
    assert expected == %HttpProxy.Play.Data{}.responses
  end

end
