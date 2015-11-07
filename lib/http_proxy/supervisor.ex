defmodule HttpProxy.Supervisor do
  use Supervisor

  @proxies Application.get_env :http_proxy, :proxies

  def start_link do
    Supervisor.start_link __MODULE__, :ok, [name: __MODULE__]
  end

  def init(:ok) do
    import Supervisor.Spec

    @proxies
    |> Enum.reduce([], fn proxy, acc ->
      module_name = "HttpProxy.Handle#{proxy.port}"
      [worker(HttpProxy.Handle, [[proxy, module_name]], [id: String.to_atom(module_name)]) | acc]
    end)
    |> supervise(strategy: :one_for_one)

  end
end
