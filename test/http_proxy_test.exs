defmodule HttpProxyTest do
  use ExUnit.Case
  doctest HttpProxy

  setup do
    HttpProxy.Supervisor.start_link([])
  end

  test "the truth" do
    assert 1 + 1 == 2
  end
end
