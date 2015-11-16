defmodule HttpProxy.Handle do
  @moduledoc false

  use Plug.Builder
  import Plug.Conn
  require Logger

  alias HttpProxy.Format

  @proxies Application.get_env :http_proxy, :proxies
  @scheme %{http: "http://", https: "https://"}
  @record Application.get_env :http_proxy, :record || false

  plug Plug.Logger
  plug :dispatch

  def start_link([proxy, module_name]) do
    Logger.info "Running Proxy with Cowboy on http://localhost:#{proxy.port} named #{module_name}"
    Plug.Adapters.Cowboy.http(__MODULE__, [], [port: proxy.port, ref: String.to_atom(module_name)])
  end

  def dispatch(conn, _opts) do
    {:ok, client} = :hackney.request :get, uri(conn), conn.req_headers, :stream, []

    conn
    |> write_proxy(client)
    |> read_proxy(client)
  end

  def uri(conn) do
    base = gen_path conn, target_proxy(conn)
    case conn.query_string do
      ""           -> base
      query_string -> base <> "?" <> query_string
    end
  end

  defp write_proxy(conn, client) do
    case read_body(conn, []) do
      {:ok, body, conn} ->
        :hackney.send_body client, body
        conn
      {:more, body, conn} ->
        :hackney.send_body client, body
        write_proxy conn, client
    end
  end

  defp read_proxy(conn, client) do
    {:ok, status, headers, client} = :hackney.start_response client
    {:ok, body} = :hackney.body client

    headers = List.keydelete headers, "Transfer-Encoding", 0

    %{conn | resp_headers: headers}
    |> send_resp(status, body)
    |> record_conn(@record)
  end

  defp record_conn(conn, record) when record == true do
    filename = HttpProxy.File.filename conn
    Format.pretty_json(conn, true)
    |> HttpProxy.File.export(filename, conn)

    conn
  end
  defp record_conn(conn, record), do: conn

  defp gen_path(conn, proxy) when proxy == nil do
    case @scheme[conn.scheme] do
      s ->
        s <> conn.host <> "/" <> Enum.join(conn.path_info, "/")
      _ ->
        raise ArgumentError, "no scheme"
    end
  end
  defp gen_path(conn, proxy), do: proxy.to <> "/" <> Enum.join(conn.path_info, "/")

  defp target_proxy(conn) do
    Enum.reduce(@proxies, [], fn proxy, acc ->
      cond do
        proxy.port == conn.port ->
          [proxy | acc]
        true ->
          acc
      end
    end)
    |> Enum.at(0)
  end
end
