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
    # p = Enum.find(@proxy.path, fn x ->
    #   IO.inspect x
    #   IO.inspect conn.path_info
    #   x.from == conn.path_info
    # end)

    # base = case p do
    #   a ->
    #     IO.inspect a
    #     @proxy.path.to <> "/" <> Enum.join(a, "/")
    #   _ ->
    #     @proxy.path.to <> "/" <> Enum.join(conn.path_info, "/")
    # end
    path = hd(@proxy.path)
    base = path.to <> "/" <> Enum.join(conn.path_info, "/")
    case conn.query_string do
      "" -> base
      qs -> base <> "?" <> qs
    end
  end
end
