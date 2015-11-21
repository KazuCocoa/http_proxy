defmodule HttpProxy.Format do
  @moduledoc false
  
  alias HttpProxy.Data, as: Data

  def pretty_json(conn, pretty) when pretty == true, do: pretty_json(conn, false) |> JSX.prettify!
  def pretty_json(conn, pretty) do
    {a, b, c, d} = conn.remote_ip

    %Data{
      request: %{
        url: url(conn),
        remote: "#{a}.#{b}.#{c}.#{d}",
        method: conn.method,
        headers: conn.req_headers, # Maybe failed to convert
        request_body: readbody(conn),
        options: conn.query_params
      },
      response: %{
        body: conn.resp_body,
        cookies: conn.resp_cookies,
        status_code: conn.status,
        headers: resp_headers(conn)
      }
    }
    |> JSX.encode!
  end

  defp readbody(conn) do
    case Plug.Conn.read_body(conn, []) do
      {:ok, body, conn} ->
        body
      {:more, body, conn} ->
        readbody conn
    end
  end
  
  defp url(conn) do
    "#{conn.scheme}://#{conn.host}:#{Integer.to_string(conn.port)}#{conn.request_path}?#{conn.query_string}"
  end
  
  defp resp_headers(conn) do
    conn.resp_headers
    |> Enum.reduce(Map.new, fn {key, value}, acc ->
      Map.put acc, key, value
    end)
  end
end
