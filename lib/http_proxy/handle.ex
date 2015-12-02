defmodule HttpProxy.Handle do
  @moduledoc false

  use Plug.Builder
  import Plug.Conn
  require Logger

  alias HttpProxy.Format
  alias HttpProxy.Utils.File, as: HttpProxyFile

  @proxies Application.get_env :http_proxy, :proxies
  @scheme %{http: "http://", https: "https://"}
  @record Application.get_env :http_proxy, :record || false
  @play Application.get_env :http_proxy, :play || false

  plug Plug.Logger
  plug :dispatch

  def start_link([proxy, module_name]) do
    Logger.info "Running Proxy with Cowboy on http://localhost:#{proxy.port} named #{module_name}"
    Plug.Adapters.Cowboy.http(__MODULE__, [], [port: proxy.port, ref: String.to_atom(module_name)])
  end

  def dispatch(conn, _opts) do
    {:ok, client} = String.downcase(conn.method)
                    |> String.to_atom
                    |> :hackney.request(uri(conn), conn.req_headers, :stream, [])
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

    cond do
      @record && @play ->
        raise ArgumentError, "should set record or play."
      @play ->
        %{conn | resp_headers: headers}
        |> play_conn
      @record ->
        %{conn | resp_headers: headers}
        |> send_resp(status, body)
        |> record_conn
      true ->
        conn
    end
  end

  defp record_conn(conn) do
    filename = HttpProxy.Utils.File.filename conn
    Format.pretty_json(conn, true)
    |> HttpProxy.Utils.File.export(filename, conn)

    conn
  end

  # TODO: Brush up
  defp play_conn(conn) do
    res_json = File.read!(HttpProxyFile.get_mapping_path <> "/sample.json")
               |> JSX.decode!
               |> Map.fetch!("response")

    response = [
      "body": Map.fetch!(res_json, "body"),
      "cookies": Map.to_list(Map.fetch!(res_json, "cookies")),
      "headers": Map.to_list(Map.fetch!(res_json, "headers"))
                 |> List.insert_at(0, {"Date", conn.resp_headers["Date"]}),
       "status_code": Map.fetch!(res_json, "status_code")
    ]

    conn = %{conn | resp_body: response[:body] }
    conn = %{conn | resp_cookies: response[:cookies] }
    conn = %{conn | status: response[:status_code] }
    conn = %{conn | resp_headers: response[:headers] }

    send_resp conn, conn.status, conn.resp_body
  end

  def play_responses() do
    HttpProxyFile
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
