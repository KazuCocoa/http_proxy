defmodule HttpProxy.Format do
  @moduledoc """
  Format some Plug.Conn and request into JSON
  """

  alias HttpProxy.Data
  alias JSX

  @type t :: %Plug.Conn{}

  @spec pretty_json!(t, binary, binary, boolean) :: binary
  def pretty_json!(conn, req_body, res_body_file, true) do
    conn
    |> pretty_json!(req_body, res_body_file, false)
    |> JSX.prettify!()
  end

  def pretty_json!(conn, req_body, res_body_file, _) do
    {a, b, c, d} = conn.remote_ip

    %Data{
      request: %{
        url: url(conn),
        remote: "#{a}.#{b}.#{c}.#{d}",
        method: conn.method,
        # Maybe failed to convert
        headers: conn.req_headers,
        request_body: req_body,
        options: conn.query_params
      },
      response: %{
        body_file: res_body_file,
        cookies: conn.resp_cookies,
        status_code: conn.status,
        headers: resp_headers(conn)
      }
    }
    |> JSX.encode!()
  end

  defp url(conn) do
    uri = %URI{}

    %URI{
      uri
      | scheme: Atom.to_string(conn.scheme),
        host: conn.host,
        port: conn.port,
        path: conn.request_path,
        query: query(conn.query_string)
    }
    |> URI.to_string()
  end

  defp query(""), do: nil
  defp query(query_string), do: query_string

  defp resp_headers(conn) do
    conn.resp_headers
    |> Enum.reduce(Map.new(), fn {key, value}, acc ->
      Map.put(acc, key, value)
    end)
  end
end
