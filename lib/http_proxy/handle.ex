defmodule HttpProxy.Handle do
  @moduledoc false

  use Plug.Builder
  import Plug.Conn
  require Logger

  alias HttpProxy.Play.Data, as: Data
  alias HttpProxy.Record.Response, as: Record
  alias HttpProxy.Play.Response, as: Play

  @proxies Application.get_env :http_proxy, :proxies
  @scheme [:http, :https]

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
      query_string -> ~s(#{base}?#{query_string})
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
      Record.record? && Play.play? ->
        raise ArgumentError, "Can't set record and play at the same time."
      Play.play? ->
        %{conn | resp_headers: headers}
        |> play_conn
      Record.record? ->
        %{conn | resp_headers: headers}
        |> send_resp(status, body)
        |> Record.record
      true ->
        conn
    end
  end

  defp play_conn(conn) do
    key = String.downcase(conn.method) <> "_" <> Integer.to_string(conn.port) <> conn.request_path

    case List.keyfind(%Data{}.responses, String.to_atom(key), 0) do
      {_, resp} ->
        res_json = Map.fetch!(resp, "response")
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
      nil ->
        conn = %{conn | resp_body: "<html>not found nil play_conn case</html>" }
        conn = %{conn | status: 404 }
        conn = %{conn | resp_cookies: [] }
        conn = %{conn | resp_headers: [] }
    end

    send_resp conn, conn.status, conn.resp_body
  end

  defp gen_path(conn, proxy) when proxy == nil do
    case conn.scheme do
      s when s in @scheme ->
        uri = %URI{}
        %URI{uri | scheme: Atom.to_string(conn.scheme), host: conn.host, path: conn.request_path}
        |> URI.to_string
      _ ->
        raise ArgumentError, "no scheme"
    end
  end
  defp gen_path(conn, proxy) do
    uri = URI.parse proxy.to
    %URI{uri | path: conn.request_path}
    |> URI.to_string
  end

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
