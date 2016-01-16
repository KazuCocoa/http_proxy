defmodule HttpProxy.Agent do

  alias HttpProxy.Play.Data
  alias HttpProxy.Play.Paths

  @spec start_link() :: {:ok, pid} | {:error, {:already_started, pid} | term}
  def start_link, do: Agent.start(&Map.new/0, name: __MODULE__)

  @spec put(atom, binary) :: :ok
  def put(key, value), do: Agent.update(__MODULE__, &Map.put(&1, key, value))

  @spec get(atom) :: binary | nil
  def get(key), do: Agent.get(__MODULE__, &Map.get(&1, key))

  @spec clear() :: :ok
  def clear do
    Data.clear_responses
    Paths.clear_paths
    Paths.clear_path_patterns
  end
end
