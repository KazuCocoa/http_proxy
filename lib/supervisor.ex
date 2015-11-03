defmodule HttpProxy.Supervisor do
  use Supervisor

  @proxy Application.get_env :http_proxy, :proxy || 8080

  def start_link(_arg) do
    Supervisor.start_link __MODULE__, :ok, [name: __MODULE__]
  end

  def init(:ok) do
    import Supervisor.Spec

#    children = Enum.reduce [], @proxy, fn conf, acc ->
#      IO.puts "Running Proxy with Cowboy on http://localhost:#{conf.port}"
#      [worker(HttpProxy, [conf], []) | acc]
#    end
#    IO.inspect children

    children = [
      worker(HttpProxy, [%{port: 4000, to: "http://yahoo.com"}], [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
