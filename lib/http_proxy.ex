defmodule HttpProxy do
  use Plug.Builder
  import Plug.Conn

  use Supervisor

  @proxy Application.get_env :http_proxy, :proxy || 8080

  plug Plug.Logger
  plug :dispatch

  def start(_argv) do
    # Should work with supervisor
    Enum.each @proxy, fn conf ->
      IO.puts "Running Proxy with Cowboy on http://localhost:#{conf.port}"
      Plug.Adapters.Cowboy.http __MODULE__, [], port: conf.port
    end
    :timer.sleep(:infinity)
  end

  def dispatch(conn, _opts) do
    current_proxy = @proxy
                    |> Enum.find(nil, fn conf ->
                      conn.port == conf.port
                    end)
    {:ok, client} = :hackney.request :get, uri(conn, current_proxy), conn.req_headers, :stream, []

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

  defp uri(conn, proxy_config) do
    base = proxy_config.to <> "/" <> Enum.join(conn.path_info, "/")
    case conn.query_string do
      "" -> base
      qs -> base <> "?" <> qs
    end
  end
end
