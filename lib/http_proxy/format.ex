defmodule HttpProxy.Data do
  @derive [Poison.Encoder]
  defstruct [
    # request: [:host, :port, :remote, :method, :scheme, :request_path, :req_headers, :query_string, :query_body, :cookies, :query_params, :req_cookies],
    request: [:host, :port, :remote, :method, :scheme, :request_path, :req_headers, :query_string, :query_body, :query_params],
    # response: [:resp_body, :resp_cookies, :scheme, :status]
    response: [:resp_body, :scheme, :status]
  ]
end

# TODO: update formats
defmodule HttpProxy.Format do
  @moduledoc false

  def pretty_json(conn, pretty) when pretty == true do
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
        # req_headers: conn.req_headers, # fail to encord "cookies".
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
    } |> Poison.encode!([pretty: true])
  end

  defp readbody(conn) do
    case Plug.Conn.read_body(conn, []) do
      {:ok, body, conn} ->
        body
      {:more, body, conn} ->
        readbody conn
    end
  end
end
