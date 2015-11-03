defmodule HttpProxy.Supervisor do
  use Supervisor

  @proxy Application.get_env :http_proxy, :proxy

  def start_link(_arg) do
    Supervisor.start_link __MODULE__, :ok, [name: __MODULE__]
  end

  def init(:ok) do
    import Supervisor.Spec

   children = [
     worker(HttpProxy, [@proxy], [])
   ]

    supervise children, strategy: :one_for_one
  end
end
