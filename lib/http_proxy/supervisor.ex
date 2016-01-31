defmodule HttpProxy.Supervisor do
  @moduledoc """
  Supervisor for HttpProxy
  """

  use Supervisor
  alias HttpProxy.Handle
  alias HttpProxy.Agent, as: ProxyAgent

  def start_link, do: Supervisor.start_link __MODULE__, :ok, [name: __MODULE__]

  ## Callbacks

  def init(:ok) do
    Handle.proxies
    |> proxies?
    |> Enum.reduce([], fn proxy, acc ->
      module_name = "HttpProxy.Handle#{proxy.port}"
      [worker(Handle, [[proxy, module_name]], [id: String.to_atom(module_name)]) | acc]
    end)
    |> Enum.into([worker(ProxyAgent, [])])
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
                   to:   "http://google.com"},
                 %{port: 4001,
                   to:   "http://yahoo.com"}
                ],
      record: false,
      play: false,
      export_path: "test/example",
      play_path: "test/data"
    ---
    """
    raise ArgumentError, msg
  end
  defp proxies?(proxies), do: proxies
end
