defmodule HttpProxy.AgentTest do
  use ExUnit.Case

  alias HttpProxy.Agent, as: ProxyAgent

  test "get and put value" do
    assert ProxyAgent.get(:example) == nil

    ProxyAgent.put :example, "sample data"
    assert ProxyAgent.get(:example) == "sample data"
  end
end
