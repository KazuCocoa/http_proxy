defmodule HttpProxy.Format do
  @moduledoc false

  alias HttpProxy.Data, as: Data
  # require IEx

  @type t :: %Plug.Conn{}

  @spec pretty_json(t, binary, binary, boolean) :: binary
  def pretty_json(conn, req_body, resp_body, pretty) when pretty == true, do: pretty_json(conn, req_body, resp_body, false) |> JSX.prettify!
  def pretty_json(conn, req_body, resp_body, _) do
    {a, b, c, d} = conn.remote_ip

    %Data{
      request: %{
        url: url(conn),
        remote: ~s(#{a}.#{b}.#{c}.#{d}),
        method: conn.method,
        headers: conn.req_headers, # Maybe failed to convert
        request_body: req_body,
        options: conn.query_params
      },
      response: %{
        body: resp_body,
        cookies: conn.resp_cookies,
        status_code: conn.status,
        headers: resp_headers(conn)
      }
    }
    |> JSX.encode!
  end

  defp url(conn) do
    uri = %URI{}
    %URI{uri | scheme: Atom.to_string(conn.scheme), host: conn.host, port: conn.port,
                 path: conn.request_path, query: conn.query_string}
    |> URI.to_string
  end

  defp resp_headers(conn) do
    conn.resp_headers
    |> Enum.reduce(Map.new, fn {key, value}, acc ->
      Map.put acc, key, value
    end)
  end
end
