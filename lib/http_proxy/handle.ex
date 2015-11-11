defmodule HttpProxy.Data do
  @derive [Poison.Encoder]
  defstruct [
    request: [:host, :port, :remote, :method, :scheme, :request_path, :req_headers, :query_string, :query_body, :cookies, :query_params, :req_cookies],
    response: [:resp_body, :resp_cookies, :scheme, :status]
  ]
end


defmodule HttpProxy.Handle do
  @moduledoc false

  use Plug.Builder
  import Plug.Conn
  require Logger

  @proxies Application.get_env :http_proxy, :proxies
  @scheme %{http: "http://", https: "https://"}

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
    |> record
  end

  # TODO: output connection
  defp record(conn) do
    {a, b, c, d} = conn.remote_ip
    headers =  conn.resp_headers
               |> Enum.reduce(Map.new, fn {key, value}, acc ->
                 Map.put acc, key, value
               end)

    %HttpProxy.Data{
      request: %{
        host: conn.host,
        port: conn.port,
        remote: "#{a}.#{b}.#{c}.#{d}",
        method: conn.method,
        scheme: conn.scheme,
        request_path: conn.request_path,
        req_headers: conn.req_headers,
        query_string: conn.query_string,
        query_body: readbody(conn),
        cookies: conn.cookies,
        query_params: conn.query_params,
        req_cookies: conn.req_cookies
      },
      response: %{
        resp_body: conn.resp_body,
        resp_cookies: conn.resp_cookies,
        scheme: conn.scheme,
        status: conn.status,
        cach_control: headers["Cache-Control"] || "",
        content_type: headers["Content-Type"] || "",
        date: headers["Date"] || "",
        expire: headers["Expires"] || "",
        location: headers["Location"] || "",
        server: headers["Server"] || "",
        x_content_type_option: headers["X-Content-Type-Options"] || "",
        x_xss_protection: headers["X-XSS-Protection"] || ""
      }
    } # |> Poison.encode!
      # |> IO.inspect

    conn
  end

  defp readbody(conn) do
    case read_body(conn, []) do
      {:ok, body, conn} ->
        body
      {:more, body, conn} ->
        readbody conn
    end
  end

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
