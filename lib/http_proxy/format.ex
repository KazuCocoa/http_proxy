defmodule HttpProxy.Data do
  @derive [JSX.Encoder]
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

    request_url = "#{conn.scheme}://#{conn.host}:#{Integer.to_string(conn.port)}#{conn.request_path}?#{conn.query_string}"

    %HttpProxy.Data{
      request: %{
        url: request_url,
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
        headers: %{
          "Cache-Control": headers["Cache-Control"] || "",
          "Content-Type": headers["Content-Type"] || "",
          "Date": headers["Date"] || "",
          "Expires": headers["Expires"] || "",
          "Location": headers["Location"] || "",
          "Server": headers["Server"] || "",
          "X-Content-Type-Options": headers["X-Content-Type-Options"] || "",
          "X-XSS-Protection": headers["X-XSS-Protection"] || ""
        }
      }
    }
    |> JSX.encode!
    |> JSX.prettify!
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
