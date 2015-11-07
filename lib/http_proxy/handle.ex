defmodule HttpProxy.Handle do
  use Plug.Builder
  import Plug.Conn
  require Logger

  @proxies Application.get_env :http_proxy, :proxies

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
  end

  defp uri(conn) do
    base = gen_path conn, matched_path(conn)
    case conn.query_string do
      "" -> base
      qs -> base <> "?" <> qs
    end
  end

  defp matched_path(conn) do
    Enum.find(target_proxy(conn).path, fn path ->
      case Enum.at(conn.path_info, 0) do
        nil ->
          "" == path.from
        other ->
          other == path.from
      end
    end)
  end

  defp gen_path(conn, path) when path == nil, do: target_proxy(conn).default_to <> "/" <> Enum.join(conn.path_info, "/")
  defp gen_path(conn, path), do: path.to <> "/" <> Enum.join(conn.path_info, "/")

  defp target_proxy(conn), do: Enum.find @proxies, fn proxy -> proxy.port == conn.port end
end
