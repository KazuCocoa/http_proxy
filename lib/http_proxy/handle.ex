defmodule HttpProxy.Handle do
  @moduledoc """
  Handle every http request to outside of the server.
  """

  use Plug.Builder
  import Plug.Conn
  require Logger

  alias HttpProxy.Play.Data, as: Data
  alias HttpProxy.Record.Response, as: Record
  alias HttpProxy.Play.Response, as: Play

  @default_schemes [:http, :https]

  plug Plug.Logger
  plug :dispatch

  # Same as Plug.Conn https://github.com/elixir-lang/plug/blob/576c04c2cba778f1ac9ca28aa71c50efa1046b50/lib/plug/conn.ex#L125
  @type t :: %Plug.Conn{}

  @type param :: binary | [param]

  @doc """
  Start Cowboy http process with localhost and arbitrary port.
  Clients access to local Cowboy process with HTTP potocol.
  """
  @spec start_link([binary]) :: pid
  def start_link([proxy, module_name]) do
    Logger.info "Running Proxy with Cowboy on http://localhost:#{proxy.port} named #{module_name}, timeout: #{req_timeout}"
    Plug.Adapters.Cowboy.http(__MODULE__, [], cowboy_options(proxy.port, module_name))
  end

  # see https://github.com/elixir-lang/plug/blob/master/lib/plug/adapters/cowboy.ex#L5
  defp cowboy_options(port, module_name) do
    [port: port, ref: String.to_atom(module_name), timeout: req_timeout]
  end

  defp req_timeout do
    Application.get_env(:http_proxy, :timeout) || 5_000
  end

  @doc """
  Dispatch connection and Play/Record http/https requests.
  """
  @spec dispatch(t, param) :: t
  def dispatch(conn, _opts) do
    {:ok, client} = String.downcase(conn.method)
                    |> String.to_atom
                    |> :hackney.request(uri(conn), conn.req_headers, :stream, [connect_timeout: req_timeout, recv_timeout: req_timeout])
    {conn, ""}
    |> write_proxy(client)
    |> read_proxy(client)
  end

  @spec uri(t) :: String.t
  def uri(conn) do
    base = gen_path conn, target_proxy(conn)
    case conn.query_string do
      ""           -> base
      query_string -> ~s(#{base}?#{query_string})
    end
  end

  @doc ~S"""
  Get proxy defined in config/config.exs

  ## Example

      iex> HttpProxy.Handle.proxies
      [%{port: 8080, to: "http://google.com"}, %{port: 8081, to: "http://neko.com"}]
  """
  @spec proxies() :: []
  def proxies do
    Application.get_env :http_proxy, :proxies, nil
  end

  @doc ~S"""
  Get schemes which is defined as deault.

  ## Example

      iex> HttpProxy.Handle.schemes
      [:http, :https]
  """
  @spec schemes() :: []
  def schemes do
    @default_schemes
  end

  defp write_proxy({conn, req_body}, client) do
    case read_body(conn, [read_timeout: req_timeout]) do
      {:ok, body, conn} ->
        :hackney.send_body client, body
        {conn, body}
      {:more, body, conn} ->
        :hackney.send_body client, body
        write_proxy {conn, req_body <> body}, client
    end
  end

  defp read_proxy({conn, req_body}, client) do
    case :hackney.start_response client do
      {:ok, status, headers, client} ->
        {:ok, res_body} = :hackney.body client
        resd_request(%{conn | resp_headers: headers}, req_body, res_body, status)
      {:error, message} ->
        resd_request(%{conn | resp_headers: conn.resp_headers}, req_body, Atom.to_string(message), 408)
    end
  end

  defp resd_request(conn, req_body, res_body, status) do
    cond do
      Record.record? && Play.play? ->
        raise ArgumentError, "Can't set record and play at the same time."
      Play.play? ->
        conn
        |> play_conn
      Record.record? ->
        conn
        |> send_resp(status, res_body)
        |> Record.record(req_body, res_body)
      true ->
        conn
        |> send_resp(status, res_body)
    end
  end

  # TODO: do matthing request_path
  # 1. path_patternか、pathを持っているかで分岐
  # 2. path_patternを持たない場合、keyの完全一致で判断
  # 3. path_patternを持っている場合、Response.pattern/2 で、conn.request_pathとpath_patternでパターンマッチ
  # 4. trueなら、その対応する応答を返す。falseなら404
  defp play_conn(conn) do
    prefix_key = ~s(#{String.downcase(conn.method)}_)
    request_path_key = Integer.to_string(conn.port) <> conn.request_path
    case Keyword.fetch(%Data{}.responses, String.to_atom(prefix_key <> request_path_key)) do
      {:ok, resp} ->
        response = resp |> gen_response(conn)
        conn = %{conn | resp_body: response[:body], resp_cookies: response[:cookies], status: response[:status_code], resp_headers: response[:headers]}
      :error ->
        conn = no_match conn
    end

    send_resp conn, conn.status, conn.resp_body
  end

  defp no_match(conn) do
    %{conn | resp_body: "<html>not found nil play_conn case</html>", status: 404, resp_cookies: [], resp_headers: []}
  end

  defp gen_response(resp, conn) do
    res_json = Map.fetch!(resp, "response")
    [
      "body": Map.fetch!(res_json, "body"),
      "cookies": Map.to_list(Map.fetch!(res_json, "cookies")),
      "headers": Map.to_list(Map.fetch!(res_json, "headers"))
                 |> List.insert_at(0, {"Date", conn.resp_headers["Date"]}),
       "status_code": Map.fetch!(res_json, "status_code")
    ]
  end

  defp gen_path(conn, proxy) when proxy == nil do
    case conn.scheme do
      s when s in @default_schemes ->
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
    Enum.reduce(proxies, [], fn proxy, acc ->
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
