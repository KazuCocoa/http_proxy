defmodule HttpProxy.SupervisorTest do
  use ExUnit.Case, async: true

  test "check subversion tree" do
    pid = Process.whereis HttpProxy.Supervisor
    assert pid != nil

    children = Supervisor.which_children HttpProxy.Supervisor
    {id, _, _, modules} = hd(children)

    assert Enum.count(children) == 2
    assert id == :"HttpProxy.Handle8080"
    assert modules == [HttpProxy.Handle]
  end
end
