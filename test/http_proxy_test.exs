defmodule HttpProxyTest do
  use ExUnit.Case, async: true
  use ExUnit.Parametarized
  use Plug.Test

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
        "no proxy":  {"http://localhost:8082/", "http://localhost/" },
        "no proxy":  {"https://localhost:8082/", "https://localhost/" },
      ]
    end

end
