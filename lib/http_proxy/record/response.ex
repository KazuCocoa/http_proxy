defmodule HttpProxy.Record.Response do
  @moduledoc false

  alias HttpProxy.Format
  alias HttpProxy.Utils.File, as: HttpProxyFile

  @type t :: %Plug.Conn{}

  @spec record?() :: boolean
  def record?, do: Application.get_env :http_proxy, :record, false

  @spec record(t, binary, binary) :: t
  def record(conn, req_body, res_body) do
    export_mapping = HttpProxyFile.get_export_path(conn.port)
    export_body = HttpProxyFile.get_export_binary_path(conn.port)
    filename = HttpProxyFile.filename(conn.path_info)

    conn
    |> Format.pretty_json!(req_body, export_body <> "/" <> filename, true)
    |> HttpProxyFile.export(export_mapping, filename)

    res_body
    |> HttpProxyFile.export(export_body, filename)

    conn
  end
end
