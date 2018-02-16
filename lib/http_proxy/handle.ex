defmodule HttpProxy.Handle do
  @moduledoc """
  Handle every http request to outside of the server.
  """

  use Plug.Builder
  import Plug.Conn
  require Logger

  if Mix.env() == :dev do
    use Plug.Debugger, otp_app: :http_proxy
  end

  alias Plug.Conn
  alias Plug.Adapters.Cowboy, as: PlugCowboy

  alias HttpProxy.Play.Data
  alias HttpProxy.Record.Response, as: Record
  alias HttpProxy.Play.Response, as: Play
  alias HttpProxy.Play.Paths, as: PlayPaths
  alias HttpProxy.Play.Body, as: PlayBody

  alias JSX

  @default_schemes [:http, :https]

  plug(Plug.Logger)
  plug(:dispatch)

  # Same as Plug.Conn https://github.com/elixir-lang/plug/blob/576c04c2cba778f1ac9ca28aa71c50efa1046b50/lib/plug/conn.ex#L125

  @type param :: binary | [param]

  @doc """
  Start Cowboy http process with localhost and arbitrary port.
  Clients access to local Cowboy process with HTTP potocol.
  """
  @spec start_link([binary]) :: pid
  def start_link([proxy, module_name]) do
    Logger.info(fn ->
      "Running #{__MODULE__} on http://localhost:#{proxy.port} named #{module_name}, timeout: #{
        req_timeout()
      }"
    end)

    PlugCowboy.http(__MODULE__, [], cowboy_options(proxy.port, module_name))
  end

  # see https://github.com/elixir-lang/plug/blob/master/lib/plug/adapters/cowboy.ex#L5
  defp cowboy_options(port, module_name),
    do: [port: port, ref: String.to_atom(module_name), timeout: req_timeout()]

  defp req_timeout, do: Application.get_env(:http_proxy, :timeout, 5000)

  @doc """
  Dispatch connection and Play/Record http/https requests.
  """
  @spec dispatch(Plug.Conn.t(), param) :: Plug.Conn.t()
  def dispatch(conn, _opts) do
    {:ok, client} =
      conn.method
      |> String.downcase()
      |> String.to_atom()
      |> :hackney.request(
        uri(conn),
        conn.req_headers,
        :stream,
        connect_timeout: req_timeout(),
        recv_timeout: req_timeout(),
        ssl_options: [],
        max_redirect: 5
      )

    {conn, ""}
    |> write_proxy(client)
    |> read_proxy(client)
  end

  @spec uri(Plug.Conn.t()) :: String.t()
  def uri(conn) do
    base = gen_path(conn, target_proxy(conn))

    case conn.query_string do
      "" ->
        base

      query_string ->
        "#{base}?#{query_string}"
    end
  end

  @doc ~S"""
  Get proxy defined in config/config.exs

  ## Example

      iex> HttpProxy.Handle.proxies
      [%{port: 8080, to: "http://google.com"}, %{port: 8081, to: "http://www.google.co.jp"}]
  """
  @spec proxies() :: []
  def proxies, do: Application.get_env(:http_proxy, :proxies, nil)

  @doc ~S"""
  Get schemes which is defined as deault.

  ## Example

      iex> HttpProxy.Handle.schemes
      [:http, :https]
  """
  @spec schemes() :: []
  def schemes, do: @default_schemes

  defp write_proxy({conn, _req_body}, client) do
    case read_body(conn, read_timeout: req_timeout()) do
      {:ok, body, conn} ->
        Logger.debug(fn -> "request path: #{gen_path(conn, target_proxy(conn))}" end)

        Logger.debug(fn ->
          "#{__MODULE__}.write_proxy, :ok, headers: #{conn.req_headers |> JSX.encode!()}, body: #{
            body
          }"
        end)

        :hackney.send_body(client, body)
        {conn, body}

      {:more, body, conn} ->
        Logger.debug(fn -> "request path: #{gen_path(conn, target_proxy(conn))}" end)
        Logger.debug(fn -> "#{__MODULE__}.write_proxy, :more, body: #{body}" end)
        :hackney.send_body(client, body)
        write_proxy({conn, ""}, client)
        {conn, body}

      {:error, term} ->
        Logger.error(term)
    end
  end

  defp read_proxy({conn, req_body}, client) do
    case :hackney.start_response(client) do
      {:ok, status, headers, client} ->
        Logger.debug(fn -> "request path: #{gen_path(conn, target_proxy(conn))}" end)

        Logger.debug(fn ->
          "#{__MODULE__}.read_proxy, :ok, headers: #{headers |> JSX.encode!()}, status: #{status}"
        end)

        {:ok, res_body} = :hackney.body(client)
        read_request(%{conn | resp_headers: headers}, req_body, res_body, status)

      {:error, message} ->
        Logger.debug(fn -> "request path: #{gen_path(conn, target_proxy(conn))}" end)
        Logger.debug(fn -> "#{__MODULE__}.read_proxy, :error, message: #{message}" end)

        read_request(
          %{conn | resp_headers: conn.resp_headers},
          req_body,
          Atom.to_string(message),
          408
        )
    end
  end

  defp read_request(conn, req_body, res_body, status) do
    cond do
      Record.record?() && Play.play?() ->
        raise ArgumentError, "Can't set record and play at the same time."

      Play.play?() ->
        conn
        |> play_conn

      Record.record?() ->
        conn
        |> send_resp(status, res_body)
        |> Record.record(req_body, res_body)

      true ->
        conn
        |> send_resp(status, res_body)
    end
  end

  defp play_conn(conn) do
    conn =
      matched_path?(
        conn,
        PlayPaths.path?(conn.request_path) || PlayPaths.path_pattern?(conn.request_path)
      )

    send_resp(conn, conn.status, conn.resp_body)
  end

  defp no_match(conn) do
    %{conn | resp_body: "{not found nil play_conn case}", resp_cookies: [], resp_headers: []}
    |> Conn.put_status(404)
  end

  defp matched_path?(conn, nil), do: no_match(conn)

  defp matched_path?(conn, matched_path) do
    prefix_key = String.downcase(conn.method) <> "_" <> Integer.to_string(conn.port)

    case Keyword.fetch(Data.responses(), String.to_atom(prefix_key <> matched_path)) do
      {:ok, resp} ->
        response = resp |> gen_response(conn)

        %{
          conn
          | resp_body: response[:body],
            resp_cookies: response[:cookies],
            resp_headers: response[:headers]
        }
        |> Conn.put_status(response[:status_code])

      :error ->
        no_match(conn)
    end
  end

  defp gen_response(resp, conn) do
    res_json = Map.fetch!(resp, "response")

    [
      body: PlayBody.get_body(resp),
      cookies: Map.to_list(Map.fetch!(res_json, "cookies")),
      headers:
        res_json
        |> Map.fetch!("headers")
        |> Map.to_list()
        |> List.insert_at(0, {"Date", hd(Conn.get_resp_header(conn, "Date"))}),
      status_code: Map.fetch!(res_json, "status_code")
    ]
  end

  defp gen_path(conn, proxy) when proxy == nil do
    case conn.scheme do
      s when s in @default_schemes ->
        %URI{
          %URI{}
          | scheme: Atom.to_string(conn.scheme),
            host: conn.host,
            path: conn.request_path
        }
        |> URI.to_string()

      _ ->
        raise ArgumentError, "no scheme"
    end
  end

  defp gen_path(conn, proxy) do
    uri = URI.parse(proxy.to)

    %URI{uri | path: conn.request_path}
    |> URI.to_string()
  end

  defp target_proxy(conn) do
    proxies()
    |> Enum.reduce([], fn proxy, acc ->
      if proxy.port == conn.port, do: [proxy | acc], else: acc
    end)
    |> Enum.at(0)
  end
end
