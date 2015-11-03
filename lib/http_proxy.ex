defmodule HttpProxy do
  use Plug.Builder
  import Plug.Conn

  @proxy Application.get_env :http_proxy, :proxy

  plug Plug.Logger
  plug :dispatch


  def start_link(proxy) do
    IO.puts "Running Proxy with Cowboy on http://localhost:#{proxy.port}"
    Plug.Adapters.Cowboy.http __MODULE__, [], port: proxy.port
    :timer.sleep(:infinity)
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
    base = generate_path conn, matched_path(conn)
    case conn.query_string do
      "" -> base
      qs -> base <> "?" <> qs
    end
  end

  defp matched_path(conn) do
    Enum.find(@proxy.path, fn path ->
      case Enum.at(conn.path_info, 0) do
        nil ->
          "" == path.from
        other ->
          other == path.from
      end
    end)
  end

  defp generate_path(conn, config_path) do
    case config_path do
      nil ->
        @proxy.default_to <> "/" <> Enum.join(conn.path_info, "/")
      _ ->
        config_path.to <> "/" <> Enum.join(conn.path_info, "/")
    end
  end
end
