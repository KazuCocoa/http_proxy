defmodule HttpProxy.SupervisorTest do
  use ExUnit.Case, async: false

  test "check subversion tree" do
    pid = Process.whereis HttpProxy.Supervisor
    assert pid != nil

    children = Supervisor.which_children HttpProxy.Supervisor
    assert Enum.count(children) == 3

    {id, _, _, modules} = hd(children)
    assert id == :"HttpProxy.Handle8080"
    assert modules == [HttpProxy.Handle]

    {id, _, _, modules} = List.last(children)
    assert "#{id}" == "Elixir.HttpProxy.Agent"
    assert modules == [HttpProxy.Agent]
  end
end
