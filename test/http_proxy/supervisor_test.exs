defmodule HttpProxy.SupervisorTest do
  use ExUnit.Case, async: true

  test "check subversion tree" do
    pid = Process.whereis(HttpProxy.Supervisor)
    assert pid != nil

    children = Supervisor.which_children(HttpProxy.Supervisor)
    assert Enum.count(children) == 3

    {id, _, _, modules} = hd(children)
    assert id == :"HttpProxy.Handle8080"
    assert modules == [HttpProxy.Handle]

    {id, _, _, modules} = List.last(children)
    assert id == HttpProxy.Agent
    assert modules == [HttpProxy.Agent]
  end

  test "proxies is nil when launch supervisor" do
    proxy = Application.get_env(:http_proxy, :proxies, nil)
    Application.delete_env :http_proxy, :proxies

    assert_raise ArgumentError, fn ->
      HttpProxy.Supervisor.init(:ok)
    end

    Application.put_env(:http_proxy, :proxies, proxy)
  end
end
