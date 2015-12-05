defmodule HttpProxy.Record.Response do
  @moduledoc false

  alias HttpProxy.Format
  alias HttpProxy.Utils.File, as: HttpProxyFile

  @record Application.get_env :http_proxy, :record || false

  def record?, do: @record

  def record(conn) do
    export = HttpProxyFile.get_export_path(conn.port)
    filename = HttpProxyFile.filename(conn.path_info)

    Format.pretty_json(conn, true)
    |> HttpProxyFile.export(export, filename)

    conn
  end
end
