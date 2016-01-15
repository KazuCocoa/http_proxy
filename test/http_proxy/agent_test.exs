defmodule HttpProxy.AgentTest do
  use ExUnit.Case, async: false

  alias HttpProxy.Agent, as: ProxyAgent

  test "get and put value" do
    assert ProxyAgent.get(:example) == nil

    ProxyAgent.put :example, "sample data"
    assert ProxyAgent.get(:example) == "sample data"
  end

  test "clear data" do
    assert ProxyAgent.get(:play_responses) != nil
    assert ProxyAgent.get(:play_paths) != nil
    assert ProxyAgent.get(:play_path_patterns) != nil

    ProxyAgent.clear

    assert ProxyAgent.get(:play_responses) == nil
    assert ProxyAgent.get(:play_paths) == nil
    assert ProxyAgent.get(:play_path_patterns) == nil
  end
end
