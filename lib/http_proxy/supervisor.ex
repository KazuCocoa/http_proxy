defmodule HttpProxy.Supervisor do
  use Supervisor

  @proxies Application.get_env :http_proxy, :proxies

  def start_link do
    Supervisor.start_link __MODULE__, :ok, [name: __MODULE__]
  end

  def init(:ok) do
    import Supervisor.Spec

    proxies?(@proxies)
    |> Enum.reduce([], fn proxy, acc ->
      module_name = "HttpProxy.Handle#{proxy.port}"
      [worker(HttpProxy.Handle, [[proxy, module_name]], [id: String.to_atom(module_name)]) | acc]
    end)
    |> supervise(strategy: :one_for_one)
  end

  defp proxies?(nil) do
    msg = ~s"""
    You should set config/config.exs like the following lines.

    ---
    use Mix.Config

    config :http_proxy,
      proxies: [
        %{port: 4000,
          default_to: "http://google.com",
          path: [
            %{from: "", to: "http://yahoo.com"},
            %{from: "neko", to: "http://yahoo.co.jp"}
          ]
          }
        ]
    ---
    """
    raise ArgumentError, msg
  end
  defp proxies?(proxies), do: proxies
end
