defmodule HttpProxy.Record.Response do
  @moduledoc false

  alias HttpProxy.Format
  alias HttpProxy.Utils.File, as: HttpProxyFile

  @type t :: %Plug.Conn{}

  @spec record?() :: boolean
  def record?, do: Application.get_env :http_proxy, :record, false

  @spec record(t, binary, binary) :: t
  def record(conn, req_body, res_body) do
    export = HttpProxyFile.get_export_path(conn.port)
    filename = HttpProxyFile.filename(conn.path_info)

    Format.pretty_json(conn, req_body, res_body, true)
    |> HttpProxyFile.export(export, filename)

    conn
  end
end
