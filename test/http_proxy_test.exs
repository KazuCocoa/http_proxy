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
        "root": {"http://localhost:8080/", "http://yahoo.com/" },
        "path": {"http://localhost:8081/neko", "http://yahoo.co.jp"},
        "1": {"http://localhost:8081/neko?hoge=1", "http://yahoo.co.jp/neko?hoge=1"},
        "2": {"http://localhost:8081/neko?hoge=1", "http://yahoo.co.jp/neko?hoge=1"}
      ]
    end

end
